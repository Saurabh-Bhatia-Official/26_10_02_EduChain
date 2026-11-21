package com.edlearn.backend.service;

import com.edlearn.backend.model.*;
import com.edlearn.backend.repository.*;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class LiveClassService {

    private static final String MEET_CHARS = "abcdefghijklmnopqrstuvwxyz";
    private static final SecureRandom RANDOM = new SecureRandom();

    private final LiveClassRepository liveClassRepository;
    private final AttendanceRepository attendanceRepository;
    private final ClassroomRepository classroomRepository;
    private final ClassroomMemberRepository memberRepository;

    public LiveClassService(LiveClassRepository liveClassRepository,
                            AttendanceRepository attendanceRepository,
                            ClassroomRepository classroomRepository,
                            ClassroomMemberRepository memberRepository) {
        this.liveClassRepository = liveClassRepository;
        this.attendanceRepository = attendanceRepository;
        this.classroomRepository = classroomRepository;
        this.memberRepository = memberRepository;
    }

    /**
     * Generates a 3-4-3 Google Meet link format: https://meet.google.com/abc-defg-hij
     */
    public static String generateGoogleMeetLink() {
        StringBuilder sb = new StringBuilder("https://meet.google.com/");
        for (int i = 0; i < 3; i++) sb.append(MEET_CHARS.charAt(RANDOM.nextInt(MEET_CHARS.length())));
        sb.append('-');
        for (int i = 0; i < 4; i++) sb.append(MEET_CHARS.charAt(RANDOM.nextInt(MEET_CHARS.length())));
        sb.append('-');
        for (int i = 0; i < 3; i++) sb.append(MEET_CHARS.charAt(RANDOM.nextInt(MEET_CHARS.length())));
        return sb.toString();
    }

    @Transactional
    public Map<String, Object> scheduleLiveClass(UserEntity host, UUID classroomId, Map<String, Object> body) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));

        checkTeacherOrAdmin(host, classroom);

        String title = (String) body.get("title");
        if (title == null || title.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Live class title is required.");
        }

        if (body.get("startTime") == null || body.get("endTime") == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Start time and end time are required.");
        }

        LocalDateTime startTime = parseDateTime((String) body.get("startTime"));
        LocalDateTime endTime = parseDateTime((String) body.get("endTime"));

        if (!endTime.isAfter(startTime)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Class end time must be after start time.");
        }

        String meetLink = (String) body.get("meetLink");
        if (meetLink == null || meetLink.trim().isEmpty()) {
            meetLink = generateGoogleMeetLink();
        } else {
            meetLink = meetLink.trim();
        }

        LiveClassEntity liveClass = new LiveClassEntity();
        liveClass.setClassroom(classroom);
        liveClass.setTitle(title.trim());
        liveClass.setDescription((String) body.get("description"));
        liveClass.setMeetLink(meetLink);
        liveClass.setCalendarEventId((String) body.get("calendarEventId"));
        liveClass.setStartTime(startTime);
        liveClass.setEndTime(endTime);
        liveClass.setHostTeacher(host);
        liveClass.setStatus("SCHEDULED");
        liveClass.setCreatedAt(LocalDateTime.now());

        LiveClassEntity saved = liveClassRepository.save(liveClass);
        return formatLiveClass(saved);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getClassroomLiveClasses(UserEntity user, UUID classroomId) {
        classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));

        List<LiveClassEntity> list = liveClassRepository.findByClassroomIdOrderByStartTimeDesc(classroomId);
        return list.stream().map(this::formatLiveClass).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getUpcomingForUser(UserEntity user) {
        LocalDateTime now = LocalDateTime.now().minusHours(2); // Include ongoing classes
        List<LiveClassEntity> list = liveClassRepository.findUpcomingByUserId(user.getId(), now);
        return list.stream().map(this::formatLiveClass).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> joinClass(UserEntity user, UUID liveClassId) {
        LiveClassEntity liveClass = liveClassRepository.findById(liveClassId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Live class session not found."));

        // Verify user is member of classroom or admin
        boolean isMember = memberRepository.existsByClassroomIdAndUserIdAndStatus(liveClass.getClassroom().getId(), user.getId(), "ACTIVE");
        boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());
        boolean isHost = liveClass.getHostTeacher().getId().equals(user.getId());

        if (!isMember && !isAdmin && !isHost) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You must be enrolled in this classroom to join the live session.");
        }

        LocalDateTime now = LocalDateTime.now();

        // If host joins and class was SCHEDULED, mark as IN_PROGRESS
        if (isHost && "SCHEDULED".equals(liveClass.getStatus())) {
            liveClass.setStatus("IN_PROGRESS");
            liveClassRepository.save(liveClass);
        }

        // Record attendance
        AttendanceEntity attendance = attendanceRepository.findByLiveClassIdAndUserId(liveClassId, user.getId())
                .orElseGet(() -> {
                    AttendanceEntity att = new AttendanceEntity();
                    att.setLiveClass(liveClass);
                    att.setUser(user);
                    att.setStatus("PRESENT");
                    att.setJoinTime(now);
                    return att;
                });

        if (attendance.getJoinTime() == null) {
            attendance.setJoinTime(now);
        }
        attendanceRepository.save(attendance);

        Map<String, Object> response = new HashMap<>();
        response.put("meetLink", liveClass.getMeetLink());
        response.put("title", liveClass.getTitle());
        response.put("status", liveClass.getStatus());
        response.put("message", "Attendance recorded. Connecting to Google Meet...");
        return response;
    }

    @Transactional
    public Map<String, Object> leaveClass(UserEntity user, UUID liveClassId) {
        AttendanceEntity attendance = attendanceRepository.findByLiveClassIdAndUserId(liveClassId, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Attendance record not found."));

        LocalDateTime now = LocalDateTime.now();
        attendance.setLeaveTime(now);

        if (attendance.getJoinTime() != null) {
            long minutes = Duration.between(attendance.getJoinTime(), now).toMinutes();
            attendance.setDurationMinutes((int) Math.max(0, minutes));
        }

        attendanceRepository.save(attendance);
        return Map.of("message", "Left live class session.", "durationMinutes", attendance.getDurationMinutes());
    }

    @Transactional
    public Map<String, Object> updateLiveClassStatus(UserEntity user, UUID liveClassId, String status, String recordingUrl) {
        LiveClassEntity liveClass = liveClassRepository.findById(liveClassId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Live class not found."));

        checkTeacherOrAdmin(user, liveClass.getClassroom());

        if (status != null && !status.isBlank()) {
            liveClass.setStatus(status.toUpperCase(Locale.ROOT));
        }
        if (recordingUrl != null) {
            liveClass.setRecordingUrl(recordingUrl.trim());
        }

        LiveClassEntity saved = liveClassRepository.save(liveClass);
        return formatLiveClass(saved);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getAttendanceReport(UserEntity user, UUID liveClassId) {
        LiveClassEntity liveClass = liveClassRepository.findById(liveClassId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Live class not found."));

        checkTeacherOrAdmin(user, liveClass.getClassroom());

        List<AttendanceEntity> attendanceList = attendanceRepository.findByLiveClassIdOrderByJoinTimeAsc(liveClassId);

        List<Map<String, Object>> attendees = attendanceList.stream().map(a -> {
            Map<String, Object> map = new HashMap<>();
            map.put("userId", a.getUser().getId());
            map.put("name", a.getUser().getName());
            map.put("email", a.getUser().getEmail());
            map.put("status", a.getStatus());
            map.put("joinTime", a.getJoinTime() != null ? a.getJoinTime().toString() : null);
            map.put("leaveTime", a.getLeaveTime() != null ? a.getLeaveTime().toString() : null);
            map.put("durationMinutes", a.getDurationMinutes());
            return map;
        }).collect(Collectors.toList());

        long activeStudents = memberRepository.countActiveStudents(liveClass.getClassroom().getId());

        return Map.of(
                "liveClass", formatLiveClass(liveClass),
                "totalEnrolled", activeStudents,
                "presentCount", attendanceList.size(),
                "attendance", attendees
        );
    }

    private boolean canManage(UserEntity user, ClassroomEntity classroom) {
        if ("admin".equalsIgnoreCase(user.getRole())) return true;
        if (classroom.getCreator().getId().equals(user.getId())) return true;
        return memberRepository.findByClassroomIdAndUserId(classroom.getId(), user.getId())
                .map(m -> "TEACHER".equalsIgnoreCase(m.getRole()) || "CO_TEACHER".equalsIgnoreCase(m.getRole()))
                .orElse(false);
    }

    private void checkTeacherOrAdmin(UserEntity user, ClassroomEntity classroom) {
        if (!canManage(user, classroom)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only classroom teachers or administrators can manage live classes.");
        }
    }

    private Map<String, Object> formatLiveClass(LiveClassEntity lc) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", lc.getId());
        map.put("classroomId", lc.getClassroom().getId());
        map.put("classroomName", lc.getClassroom().getName());
        map.put("title", lc.getTitle());
        map.put("description", lc.getDescription());
        map.put("meetLink", lc.getMeetLink());
        map.put("calendarEventId", lc.getCalendarEventId());
        map.put("startTime", lc.getStartTime().toString());
        map.put("endTime", lc.getEndTime().toString());
        map.put("hostName", lc.getHostTeacher().getName());
        map.put("hostEmail", lc.getHostTeacher().getEmail());
        map.put("status", lc.getStatus());
        map.put("recordingUrl", lc.getRecordingUrl());
        map.put("createdAt", lc.getCreatedAt().toString());

        LocalDateTime now = LocalDateTime.now();
        boolean isLiveNow = now.isAfter(lc.getStartTime()) && now.isBefore(lc.getEndTime()) && !"CANCELLED".equals(lc.getStatus());
        map.put("isLiveNow", isLiveNow);

        return map;
    }

    private LocalDateTime parseDateTime(String text) {
        try {
            return LocalDateTime.parse(text, DateTimeFormatter.ISO_DATE_TIME);
        } catch (Exception ex) {
            return LocalDateTime.parse(text, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
        }
    }
}
