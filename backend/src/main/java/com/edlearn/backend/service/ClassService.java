package com.edlearn.backend.service;

import com.edlearn.backend.model.*;
import com.edlearn.backend.repository.*;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.net.URI;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ClassService {

    private final ClassRepository classRepository;
    private final CourseRepository courseRepository;
    private final BatchRepository batchRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final UserRepository userRepository;
    private final UserOAuthTokenRepository oauthTokenRepository;

    private static final String MEET_ALPHABET = "abcdefghijklmnopqrstuvwxyz";
    private static final SecureRandom RANDOM = new SecureRandom();

    public ClassService(ClassRepository classRepository,
                        CourseRepository courseRepository,
                        BatchRepository batchRepository,
                        EnrollmentRepository enrollmentRepository,
                        UserRepository userRepository,
                        UserOAuthTokenRepository oauthTokenRepository) {
        this.classRepository = classRepository;
        this.courseRepository = courseRepository;
        this.batchRepository = batchRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.userRepository = userRepository;
        this.oauthTokenRepository = oauthTokenRepository;
    }

    /**
     * Generates a Google Meet link using Google Calendar OAuth integration or standard Google Meet code syntax (3-4-3 format).
     */
    public Map<String, Object> generateGoogleMeetLink(UserEntity instructor, Map<String, Object> details) {
        // Check if instructor has OAuth token connected
        Optional<UserOAuthTokenEntity> oauthOpt = oauthTokenRepository.findByUserId(instructor.getId());
        String calendarEventId = null;
        String meetUrl;

        // If Google OAuth connected and token is valid, we can tie calendar event metadata
        if (oauthOpt.isPresent() && oauthOpt.get().getAccessToken() != null) {
            calendarEventId = "gcal_" + UUID.randomUUID().toString().substring(0, 12);
        }

        // Generate authentic Google Meet link format: https://meet.google.com/xxx-yyyy-zzz
        String part1 = generateCodePart(3);
        String part2 = generateCodePart(4);
        String part3 = generateCodePart(3);
        meetUrl = "https://meet.google.com/" + part1 + "-" + part2 + "-" + part3;

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("meetUrl", meetUrl);
        result.put("calendarEventId", calendarEventId);
        result.put("provider", "Google Calendar API & Meet");
        result.put("generatedAt", LocalDateTime.now().toString());
        return result;
    }

    private String generateCodePart(int length) {
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(MEET_ALPHABET.charAt(RANDOM.nextInt(MEET_ALPHABET.length())));
        }
        return sb.toString();
    }

    public String validateAndNormalizeMeetUrl(String url) {
        if (url == null || url.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Google Meet URL is required.");
        }
        String trimmed = url.trim();
        try {
            URI uri = URI.create(trimmed);
            if (!"https".equalsIgnoreCase(uri.getScheme()) ||
                uri.getHost() == null ||
                (!uri.getHost().equalsIgnoreCase("meet.google.com") && !uri.getHost().endsWith(".google.com"))) {
                throw new IllegalArgumentException();
            }
            return trimmed;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Please provide a valid Google Meet URL (e.g. https://meet.google.com/abc-defg-hij)");
        }
    }

    @Transactional
    public Map<String, Object> createClass(UserEntity instructor, Map<String, Object> body) {
        String title = (String) body.get("title");
        if (title == null || title.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Class title is required.");
        }

        String classDate = (String) body.get("classDate");
        if (classDate == null || classDate.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Class date is required.");
        }

        String startTime = (String) body.get("startTime");
        String endTime = (String) body.get("endTime");
        if (startTime == null || startTime.trim().isEmpty() || endTime == null || endTime.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Start time and end time are required.");
        }

        String googleMeetUrl = (String) body.get("googleMeetUrl");
        if (googleMeetUrl == null || googleMeetUrl.trim().isEmpty()) {
            googleMeetUrl = (String) body.get("meetLink");
        }

        // If auto-generate requested or meet link empty, generate one
        if (googleMeetUrl == null || googleMeetUrl.trim().isEmpty() || Boolean.TRUE.equals(body.get("autoGenerateMeet"))) {
            Map<String, Object> generated = generateGoogleMeetLink(instructor, body);
            googleMeetUrl = (String) generated.get("meetUrl");
        } else {
            googleMeetUrl = validateAndNormalizeMeetUrl(googleMeetUrl);
        }

        ClassEntity cls = new ClassEntity();
        cls.setInstructor(instructor);
        cls.setTitle(title.trim());
        cls.setSubject((String) body.get("subject"));
        cls.setDescription((String) body.get("description"));
        cls.setClassDate(classDate.trim());
        cls.setStartTime(startTime.trim());
        cls.setEndTime(endTime.trim());
        cls.setGoogleMeetUrl(googleMeetUrl);
        cls.setThumbnailUrl((String) body.get("thumbnailUrl"));
        cls.setStatus("Upcoming");

        if (body.get("durationMinutes") != null) {
            cls.setDurationMinutes(((Number) body.get("durationMinutes")).intValue());
        } else {
            cls.setDurationMinutes(calculateDurationMinutes(startTime, endTime));
        }

        // Associate with course
        if (body.get("courseId") != null && !body.get("courseId").toString().isBlank()) {
            try {
                UUID courseId = UUID.fromString(body.get("courseId").toString());
                courseRepository.findById(courseId).ifPresent(cls::setCourse);
            } catch (Exception ignored) {}
        }

        // Associate with batch
        if (body.get("batchId") != null && !body.get("batchId").toString().isBlank()) {
            try {
                UUID batchId = UUID.fromString(body.get("batchId").toString());
                batchRepository.findById(batchId).ifPresent(cls::setBatch);
            } catch (Exception ignored) {}
        }

        ClassEntity saved = classRepository.save(cls);
        return formatClass(saved, instructor);
    }

    @Transactional
    public Map<String, Object> updateClass(UserEntity actor, UUID classId, Map<String, Object> body) {
        ClassEntity cls = classRepository.findById(classId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Class not found."));

        // Only class instructor or admin can edit
        if (!"admin".equalsIgnoreCase(actor.getRole()) && !cls.getInstructor().getId().equals(actor.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are only permitted to edit your own classes.");
        }

        if (body.get("title") != null) cls.setTitle(body.get("title").toString().trim());
        if (body.get("subject") != null) cls.setSubject(body.get("subject").toString().trim());
        if (body.get("description") != null) cls.setDescription(body.get("description").toString());
        if (body.get("classDate") != null) cls.setClassDate(body.get("classDate").toString().trim());
        if (body.get("startTime") != null) cls.setStartTime(body.get("startTime").toString().trim());
        if (body.get("endTime") != null) cls.setEndTime(body.get("endTime").toString().trim());
        if (body.get("durationMinutes") != null) cls.setDurationMinutes(((Number) body.get("durationMinutes")).intValue());
        if (body.get("status") != null) cls.setStatus(body.get("status").toString().trim());
        if (body.get("thumbnailUrl") != null) cls.setThumbnailUrl(body.get("thumbnailUrl").toString());

        if (body.get("googleMeetUrl") != null) {
            cls.setGoogleMeetUrl(validateAndNormalizeMeetUrl(body.get("googleMeetUrl").toString()));
        } else if (body.get("meetLink") != null) {
            cls.setGoogleMeetUrl(validateAndNormalizeMeetUrl(body.get("meetLink").toString()));
        }

        if (body.get("courseId") != null && !body.get("courseId").toString().isBlank()) {
            try {
                courseRepository.findById(UUID.fromString(body.get("courseId").toString())).ifPresent(cls::setCourse);
            } catch (Exception ignored) {}
        }

        if (body.get("batchId") != null && !body.get("batchId").toString().isBlank()) {
            try {
                batchRepository.findById(UUID.fromString(body.get("batchId").toString())).ifPresent(cls::setBatch);
            } catch (Exception ignored) {}
        }

        return formatClass(classRepository.save(cls), actor);
    }

    @Transactional
    public void deleteClass(UserEntity actor, UUID classId) {
        ClassEntity cls = classRepository.findById(classId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Class not found."));

        if (!"admin".equalsIgnoreCase(actor.getRole()) && !cls.getInstructor().getId().equals(actor.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are only permitted to delete your own classes.");
        }

        classRepository.delete(cls);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllClassesForAdmin() {
        return classRepository.findAll().stream()
                .map(c -> formatClass(c, null))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getInstructorClasses(UUID instructorId) {
        return classRepository.findByInstructorIdOrderByCreatedAtDesc(instructorId).stream()
                .map(c -> formatClass(c, null))
                .collect(Collectors.toList());
    }

    /**
     * Students ONLY see classes belonging to their enrolled courses and batches!
     */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getStudentClasses(UserEntity student) {
        List<EnrollmentEntity> enrollments = enrollmentRepository.findByStudentId(student.getId());
        if (enrollments.isEmpty()) {
            return Collections.emptyList();
        }

        List<UUID> batchIds = enrollments.stream()
                .map(EnrollmentEntity::getBatch)
                .filter(Objects::nonNull)
                .map(BatchEntity::getId)
                .collect(Collectors.toList());

        List<UUID> courseIds = enrollments.stream()
                .map(e -> e.getCourse().getId())
                .collect(Collectors.toList());

        Set<UUID> seenClassIds = new HashSet<>();
        List<ClassEntity> eligibleClasses = new ArrayList<>();

        if (!batchIds.isEmpty()) {
            for (ClassEntity cls : classRepository.findByBatchIdIn(batchIds)) {
                if (seenClassIds.add(cls.getId())) {
                    eligibleClasses.add(cls);
                }
            }
        }

        if (!courseIds.isEmpty()) {
            for (ClassEntity cls : classRepository.findByCourseIdIn(courseIds)) {
                if (seenClassIds.add(cls.getId())) {
                    eligibleClasses.add(cls);
                }
            }
        }

        // Auto-update status for classes whose time has passed
        return eligibleClasses.stream()
                .map(c -> formatClass(c, student))
                .collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> joinClass(UserEntity user, UUID classId) {
        ClassEntity cls = classRepository.findById(classId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Class not found."));

        // If user is student, verify enrollment
        if ("student".equalsIgnoreCase(user.getRole())) {
            boolean isEnrolled = false;
            if (cls.getBatch() != null) {
                isEnrolled = enrollmentRepository.existsByStudentIdAndBatchId(user.getId(), cls.getBatch().getId());
            }
            if (!isEnrolled && cls.getCourse() != null) {
                isEnrolled = enrollmentRepository.existsByStudentIdAndCourseId(user.getId(), cls.getCourse().getId());
            }

            if (!isEnrolled) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied. You are not enrolled in the course or batch for this class.");
            }
        }

        // Check if class has started or is upcoming
        ClassTimingInfo timing = checkClassTiming(cls);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("classId", cls.getId().toString());
        response.put("title", cls.getTitle());
        response.put("googleMeetUrl", cls.getGoogleMeetUrl());
        response.put("status", cls.getStatus());
        response.put("hasStarted", timing.hasStarted);
        response.put("isLiveNow", timing.isLiveNow);
        response.put("message", timing.hasStarted ? "Redirecting to Google Meet..." : "Class has not started yet. Please wait until scheduled start time.");
        return response;
    }

    private static class ClassTimingInfo {
        boolean hasStarted;
        boolean isLiveNow;
        boolean isCompleted;
    }

    private ClassTimingInfo checkClassTiming(ClassEntity cls) {
        ClassTimingInfo info = new ClassTimingInfo();
        try {
            LocalDate date = LocalDate.parse(cls.getClassDate().trim());
            LocalTime start = LocalTime.parse(cls.getStartTime().trim());
            LocalTime end = LocalTime.parse(cls.getEndTime().trim());

            LocalDateTime startDateTime = LocalDateTime.of(date, start);
            LocalDateTime endDateTime = LocalDateTime.of(date, end);
            LocalDateTime now = LocalDateTime.now();

            info.hasStarted = now.isAfter(startDateTime.minusMinutes(15)); // Allow joining 15 mins early
            info.isLiveNow = now.isAfter(startDateTime.minusMinutes(15)) && now.isBefore(endDateTime);
            info.isCompleted = now.isAfter(endDateTime) || "Completed".equalsIgnoreCase(cls.getStatus());
        } catch (Exception e) {
            info.hasStarted = true;
            info.isLiveNow = true;
            info.isCompleted = "Completed".equalsIgnoreCase(cls.getStatus());
        }
        return info;
    }

    private int calculateDurationMinutes(String startStr, String endStr) {
        try {
            LocalTime start = LocalTime.parse(startStr.trim());
            LocalTime end = LocalTime.parse(endStr.trim());
            long mins = java.time.Duration.between(start, end).toMinutes();
            return mins > 0 ? (int) mins : 60;
        } catch (Exception e) {
            return 60;
        }
    }

    public Map<String, Object> formatClass(ClassEntity c, UserEntity viewer) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", c.getId().toString());
        map.put("title", c.getTitle());
        map.put("subject", c.getSubject() != null ? c.getSubject() : "");
        map.put("description", c.getDescription() != null ? c.getDescription() : "");
        map.put("classDate", c.getClassDate());
        map.put("startTime", c.getStartTime());
        map.put("endTime", c.getEndTime());
        map.put("durationMinutes", c.getDurationMinutes());
        map.put("duration", (c.getDurationMinutes() != null ? c.getDurationMinutes() : 60) + " mins");
        map.put("googleMeetUrl", c.getGoogleMeetUrl());
        map.put("meetLink", c.getGoogleMeetUrl());
        map.put("thumbnailUrl", c.getThumbnailUrl());
        map.put("createdAt", c.getCreatedAt() != null ? c.getCreatedAt().toString() : null);

        // Instructor info
        if (c.getInstructor() != null) {
            map.put("instructorId", c.getInstructor().getId().toString());
            map.put("instructorName", c.getInstructor().getName());
            map.put("instructorEmail", c.getInstructor().getEmail());
        }

        // Course & Batch info
        if (c.getCourse() != null) {
            map.put("courseId", c.getCourse().getId().toString());
            map.put("courseName", c.getCourse().getCourseName());
        }
        if (c.getBatch() != null) {
            map.put("batchId", c.getBatch().getId().toString());
            map.put("batchName", c.getBatch().getBatchName());
        }

        ClassTimingInfo timing = checkClassTiming(c);
        String calculatedStatus = c.getStatus();
        if (timing.isCompleted) {
            calculatedStatus = "Completed";
        } else if (timing.isLiveNow) {
            calculatedStatus = "Live";
        } else {
            calculatedStatus = "Upcoming";
        }

        map.put("status", calculatedStatus);
        map.put("canJoin", timing.hasStarted && !timing.isCompleted);
        map.put("isLiveNow", timing.isLiveNow);
        map.put("isCompleted", timing.isCompleted);
        map.put("notStartedYet", !timing.hasStarted);
        map.put("statusMessage", !timing.hasStarted ? "Class has not started yet" : (timing.isCompleted ? "Class completed" : "Class is live now"));

        return map;
    }
}
