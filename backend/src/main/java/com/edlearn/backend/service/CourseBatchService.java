package com.edlearn.backend.service;

import com.edlearn.backend.model.*;
import com.edlearn.backend.repository.*;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class CourseBatchService {

    private final CourseRepository courseRepository;
    private final BatchRepository batchRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final UserRepository userRepository;
    private final StudentProfileRepository studentProfileRepository;

    public CourseBatchService(CourseRepository courseRepository,
                              BatchRepository batchRepository,
                              EnrollmentRepository enrollmentRepository,
                              UserRepository userRepository,
                              StudentProfileRepository studentProfileRepository) {
        this.courseRepository = courseRepository;
        this.batchRepository = batchRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.userRepository = userRepository;
        this.studentProfileRepository = studentProfileRepository;
    }

    // ================= Courses =================
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllCourses(String instituteCode) {
        List<CourseEntity> list;
        if (instituteCode != null && !instituteCode.isBlank()) {
            list = courseRepository.findByInstituteCodeIgnoreCaseOrderByCreatedAtDesc(instituteCode);
        } else {
            list = courseRepository.findAll();
        }
        return list.stream().map(this::formatCourse).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getCourseById(UUID id) {
        CourseEntity course = courseRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Course not found."));
        return formatCourse(course);
    }

    @Transactional
    public Map<String, Object> createCourse(UserEntity actor, Map<String, Object> body) {
        String name = (String) body.get("courseName");
        if (name == null || name.trim().isEmpty()) {
            name = (String) body.get("name");
        }
        if (name == null || name.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Course name is required.");
        }

        CourseEntity course = new CourseEntity();
        course.setCourseName(name.trim());
        course.setCourseCode((String) body.get("courseCode"));
        if (course.getCourseCode() == null || course.getCourseCode().isBlank()) {
            course.setCourseCode("CRS-" + (100 + new Random().nextInt(900)));
        }
        course.setDescription((String) body.get("description"));
        course.setThumbnailUrl((String) body.get("thumbnailUrl"));
        course.setInstituteCode(actor.getInstituteCode());

        // Assign instructor if given or if actor is instructor
        if (body.get("instructorId") != null) {
            String insIdStr = body.get("instructorId").toString();
            try {
                userRepository.findById(UUID.fromString(insIdStr)).ifPresent(course::setInstructor);
            } catch (Exception ignored) {}
        } else if ("instructor".equalsIgnoreCase(actor.getRole()) || "teacher".equalsIgnoreCase(actor.getRole())) {
            course.setInstructor(actor);
        }

        CourseEntity saved = courseRepository.save(course);

        // Auto-create default batch if requested
        String defaultBatchName = (String) body.get("defaultBatchName");
        if (defaultBatchName != null && !defaultBatchName.isBlank()) {
            BatchEntity batch = new BatchEntity(defaultBatchName.trim(), saved);
            batch.setInstituteCode(actor.getInstituteCode());
            batchRepository.save(batch);
        }

        return formatCourse(saved);
    }

    @Transactional
    public Map<String, Object> updateCourse(UUID id, Map<String, Object> body) {
        CourseEntity course = courseRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Course not found."));

        if (body.get("courseName") != null) course.setCourseName(body.get("courseName").toString().trim());
        if (body.get("courseCode") != null) course.setCourseCode(body.get("courseCode").toString().trim());
        if (body.get("description") != null) course.setDescription(body.get("description").toString());
        if (body.get("thumbnailUrl") != null) course.setThumbnailUrl(body.get("thumbnailUrl").toString());
        course.setUpdatedAt(LocalDateTime.now());

        if (body.get("instructorId") != null) {
            try {
                userRepository.findById(UUID.fromString(body.get("instructorId").toString())).ifPresent(course::setInstructor);
            } catch (Exception ignored) {}
        }

        return formatCourse(courseRepository.save(course));
    }

    @Transactional
    public void deleteCourse(UUID id) {
        CourseEntity course = courseRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Course not found."));
        courseRepository.delete(course);
    }

    // ================= Batches =================
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getBatchesForCourse(UUID courseId) {
        return batchRepository.findByCourseIdOrderByCreatedAtDesc(courseId).stream()
                .map(this::formatBatch).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllBatches(String instituteCode) {
        List<BatchEntity> list;
        if (instituteCode != null && !instituteCode.isBlank()) {
            list = batchRepository.findByInstituteCodeIgnoreCaseOrderByCreatedAtDesc(instituteCode);
        } else {
            list = batchRepository.findAll();
        }
        return list.stream().map(this::formatBatch).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> createBatch(UserEntity actor, Map<String, Object> body) {
        String batchName = (String) body.get("batchName");
        if (batchName == null || batchName.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Batch name is required.");
        }

        UUID courseId = null;
        if (body.get("courseId") != null) {
            try {
                courseId = UUID.fromString(body.get("courseId").toString());
            } catch (Exception ignored) {}
        }

        if (courseId == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Course ID is required for a batch.");
        }

        CourseEntity course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Course not found."));

        BatchEntity batch = new BatchEntity();
        batch.setBatchName(batchName.trim());
        batch.setCourse(course);
        batch.setStartDate((String) body.get("startDate"));
        batch.setEndDate((String) body.get("endDate"));
        batch.setInstituteCode(actor.getInstituteCode());

        return formatBatch(batchRepository.save(batch));
    }

    // ================= Enrollments =================
    @Transactional
    public Map<String, Object> enrollStudent(Map<String, Object> body) {
        UUID studentId = UUID.fromString(body.get("studentId").toString());
        UUID courseId = UUID.fromString(body.get("courseId").toString());
        UUID batchId = body.get("batchId") != null ? UUID.fromString(body.get("batchId").toString()) : null;

        UserEntity student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found."));
        CourseEntity course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Course not found."));
        BatchEntity batch = batchId != null ? batchRepository.findById(batchId).orElse(null) : null;

        Optional<EnrollmentEntity> existing = enrollmentRepository.findByStudentIdAndCourseIdAndBatchId(studentId, courseId, batchId);
        if (existing.isPresent()) {
            return formatEnrollment(existing.get());
        }

        EnrollmentEntity enrollment = new EnrollmentEntity(student, course, batch);
        EnrollmentEntity saved = enrollmentRepository.save(enrollment);

        // Update student profile batch if not set
        if (batch != null) {
            StudentProfileEntity profile = studentProfileRepository.findByUserId(studentId).orElseGet(() -> {
                StudentProfileEntity p = new StudentProfileEntity();
                p.setUser(student);
                p.setStudentId(student.getRollNumber() != null ? student.getRollNumber() : student.getUserId());
                return p;
            });
            profile.setBatch(batch);
            studentProfileRepository.save(profile);
        }

        return formatEnrollment(saved);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getStudentEnrollments(UUID studentId) {
        return enrollmentRepository.findByStudentId(studentId).stream()
                .map(this::formatEnrollment).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getEnrolledStudentsForCourse(UUID courseId) {
        return enrollmentRepository.findByCourseId(courseId).stream()
                .map(this::formatEnrollment).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getEnrolledStudentsForBatch(UUID batchId) {
        return enrollmentRepository.findByBatchId(batchId).stream()
                .map(this::formatEnrollment).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllEnrollments() {
        return enrollmentRepository.findAll().stream()
                .map(this::formatEnrollment).collect(Collectors.toList());
    }

    // ================= Formatters =================
    public Map<String, Object> formatCourse(CourseEntity c) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", c.getId().toString());
        map.put("courseName", c.getCourseName());
        map.put("courseCode", c.getCourseCode());
        map.put("description", c.getDescription());
        map.put("thumbnailUrl", c.getThumbnailUrl());
        map.put("instructorId", c.getInstructor() != null ? c.getInstructor().getId().toString() : null);
        map.put("instructorName", c.getInstructor() != null ? c.getInstructor().getName() : "Unassigned");
        map.put("createdAt", c.getCreatedAt() != null ? c.getCreatedAt().toString() : null);
        long batchCount = batchRepository.findByCourseIdOrderByCreatedAtDesc(c.getId()).size();
        long enrollmentCount = enrollmentRepository.countByCourseId(c.getId());
        map.put("batchCount", batchCount);
        map.put("enrollmentCount", enrollmentCount);
        return map;
    }

    public Map<String, Object> formatBatch(BatchEntity b) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", b.getId().toString());
        map.put("batchName", b.getBatchName());
        map.put("courseId", b.getCourse() != null ? b.getCourse().getId().toString() : null);
        map.put("courseName", b.getCourse() != null ? b.getCourse().getCourseName() : null);
        map.put("startDate", b.getStartDate());
        map.put("endDate", b.getEndDate());
        map.put("createdAt", b.getCreatedAt() != null ? b.getCreatedAt().toString() : null);
        long studentCount = enrollmentRepository.countByBatchId(b.getId());
        map.put("studentCount", studentCount);
        return map;
    }

    public Map<String, Object> formatEnrollment(EnrollmentEntity e) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", e.getId().toString());
        map.put("studentId", e.getStudent().getId().toString());
        map.put("studentName", e.getStudent().getName());
        map.put("studentEmail", e.getStudent().getEmail());
        map.put("courseId", e.getCourse().getId().toString());
        map.put("courseName", e.getCourse().getCourseName());
        map.put("batchId", e.getBatch() != null ? e.getBatch().getId().toString() : null);
        map.put("batchName", e.getBatch() != null ? e.getBatch().getBatchName() : "General");
        map.put("enrollmentDate", e.getEnrollmentDate() != null ? e.getEnrollmentDate().toString() : null);
        map.put("status", e.getStatus());
        return map;
    }
}
