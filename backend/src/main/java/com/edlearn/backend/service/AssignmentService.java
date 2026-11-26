package com.edlearn.backend.service;

import com.edlearn.backend.model.*;
import com.edlearn.backend.repository.*;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class AssignmentService {

    private final AssignmentRepository assignmentRepository;
    private final AssignmentSubmissionRepository submissionRepository;
    private final AssignmentAttachmentRepository attachmentRepository;
    private final GradeRepository gradeRepository;
    private final ClassroomRepository classroomRepository;
    private final ClassroomMemberRepository memberRepository;
    private final CourseRepository courseRepository;
    private final BatchRepository batchRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final CloudinaryService cloudinaryService;

    public AssignmentService(AssignmentRepository assignmentRepository,
                             AssignmentSubmissionRepository submissionRepository,
                             AssignmentAttachmentRepository attachmentRepository,
                             GradeRepository gradeRepository,
                             ClassroomRepository classroomRepository,
                             ClassroomMemberRepository memberRepository,
                             CourseRepository courseRepository,
                             BatchRepository batchRepository,
                             EnrollmentRepository enrollmentRepository,
                             CloudinaryService cloudinaryService) {
        this.assignmentRepository = assignmentRepository;
        this.submissionRepository = submissionRepository;
        this.attachmentRepository = attachmentRepository;
        this.gradeRepository = gradeRepository;
        this.classroomRepository = classroomRepository;
        this.memberRepository = memberRepository;
        this.courseRepository = courseRepository;
        this.batchRepository = batchRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.cloudinaryService = cloudinaryService;
    }

    public Map<String, Object> uploadAssignmentFile(UserEntity user, UUID classroomId, String purpose, MultipartFile file) {
        if (classroomId != null) {
            ClassroomEntity classroom = classroomRepository.findById(classroomId)
                    .orElse(null);
            if (classroom != null) {
                if ("ASSIGNMENT".equalsIgnoreCase(purpose)) {
                    checkTeacherOrAdmin(user, classroom);
                } else if ("SUBMISSION".equalsIgnoreCase(purpose)) {
                    if (!"student".equalsIgnoreCase(user.getRole()) || !isActiveStudent(user, classroom)) {
                        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only enrolled students can upload submission files for this class.");
                    }
                }
            }
        }
        if (file == null || file.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Choose a non-empty file to upload.");
        if (file.getSize() > 25L * 1024 * 1024) throw new ResponseStatusException(HttpStatus.PAYLOAD_TOO_LARGE, "Assignment files must be 25 MB or smaller.");
        String fileName = Objects.toString(file.getOriginalFilename(), "").toLowerCase(Locale.ROOT);
        Set<String> allowedExtensions = Set.of("pdf", "doc", "docx", "odt", "rtf", "txt", "png", "jpg", "jpeg", "gif", "webp", "ppt", "pptx", "xls", "xlsx", "csv", "zip");
        int extensionIndex = fileName.lastIndexOf('.');
        if (extensionIndex < 0 || !allowedExtensions.contains(fileName.substring(extensionIndex + 1))) {
            throw new ResponseStatusException(HttpStatus.UNSUPPORTED_MEDIA_TYPE, "Unsupported file type. Upload a document, PDF, image, spreadsheet, or archive.");
        }
        String folder = "educhain/assignments/" + (classroomId != null ? classroomId : "general") + "/" + purpose.toLowerCase(Locale.ROOT);
        try {
            StoredFileEntity uploaded = cloudinaryService.uploadFile(file, folder, user.getId().toString());
            Map<String, Object> result = new HashMap<>();
            result.put("fileName", uploaded.getFileName());
            result.put("fileUrl", uploaded.getFileUrl());
            result.put("fileSize", uploaded.getFileSize());
            result.put("fileType", uploaded.getContentType());
            result.put("cloudinaryPublicId", uploaded.getFileKey());
            return result;
        } catch (IOException | RuntimeException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "File storage upload failed: " + ex.getMessage());
        }
    }

    @Transactional
    public Map<String, Object> createAssignment(UserEntity user, UUID classroomId, Map<String, Object> body) {
        String title = (String) body.get("title");
        if (title == null || title.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Assignment title is required.");
        }

        AssignmentEntity assignment = new AssignmentEntity();
        assignment.setTitle(title.trim());
        assignment.setDescription((String) body.get("description"));
        assignment.setInstructions((String) body.get("instructions"));
        if (assignment.getDescription() == null || assignment.getDescription().isBlank()) {
            assignment.setDescription(assignment.getInstructions());
        }

        // Link classroom if provided
        if (classroomId != null) {
            ClassroomEntity classroom = classroomRepository.findById(classroomId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));
            checkTeacherOrAdmin(user, classroom);
            assignment.setClassroom(classroom);
        } else if (body.get("classroomId") != null && !body.get("classroomId").toString().isBlank()) {
            try {
                UUID cId = UUID.fromString(body.get("classroomId").toString());
                classroomRepository.findById(cId).ifPresent(c -> {
                    checkTeacherOrAdmin(user, c);
                    assignment.setClassroom(c);
                });
            } catch (Exception ignored) {}
        }

        // Link Course
        if (body.get("courseId") != null && !body.get("courseId").toString().isBlank()) {
            try {
                UUID courseId = UUID.fromString(body.get("courseId").toString());
                courseRepository.findById(courseId).ifPresent(assignment::setCourse);
            } catch (Exception ignored) {}
        }

        // Link Batch
        if (body.get("batchId") != null && !body.get("batchId").toString().isBlank()) {
            try {
                UUID batchId = UUID.fromString(body.get("batchId").toString());
                batchRepository.findById(batchId).ifPresent(assignment::setBatch);
            } catch (Exception ignored) {}
        }

        // Points / Maximum marks
        int points = 100;
        if (body.get("maximumMarks") instanceof Number m) {
            points = m.intValue();
        } else if (body.get("pointsPossible") instanceof Number p) {
            points = p.intValue();
        }
        if (points <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Maximum marks must be greater than zero.");
        }
        assignment.setMaximumMarks(points);
        assignment.setPointsPossible(points);

        if (body.get("startDate") != null) {
            assignment.setStartDate(parseDateTime(body.get("startDate").toString()));
        }
        if (body.get("dueDate") != null) {
            assignment.setDueDate(parseDateTime(body.get("dueDate").toString()));
        }

        if (body.get("topic") != null && !((String) body.get("topic")).isBlank()) {
            assignment.setTopic(((String) body.get("topic")).trim());
        }

        if (body.get("attachmentUrl") != null) {
            assignment.setAttachmentUrl(body.get("attachmentUrl").toString().trim());
        }

        if (body.get("allowLateSubmissions") != null) {
            assignment.setAllowLateSubmissions(Boolean.TRUE.equals(body.get("allowLateSubmissions")));
        }
        if (body.get("allowResubmission") != null) {
            assignment.setAllowResubmission(Boolean.TRUE.equals(body.get("allowResubmission")));
        }
        if (body.get("allowedFileTypes") != null) {
            assignment.setAllowedFileTypes(body.get("allowedFileTypes").toString().trim());
        }

        String status = body.get("status") == null ? "PUBLISHED" : body.get("status").toString().toUpperCase(Locale.ROOT);
        if (!Set.of("DRAFT", "PUBLISHED").contains(status)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Assignment status must be DRAFT or PUBLISHED.");
        }
        assignment.setStatus(status);
        assignment.setCreatedBy(user);
        assignment.setInstructor(user);
        assignment.setCreatedAt(LocalDateTime.now());
        assignment.setUpdatedAt(LocalDateTime.now());

        AssignmentEntity saved = assignmentRepository.save(assignment);

        // Attachments
        if (body.get("attachments") instanceof List<?> list) {
            for (Object obj : list) {
                if (obj instanceof Map<?, ?> m) {
                    AssignmentAttachmentEntity att = new AssignmentAttachmentEntity();
                    att.setAssignment(saved);
                    att.setFileName((String) m.get("fileName"));
                    att.setFileUrl(requireFileUrl(m.get("fileUrl")));
                    att.setFileType((String) m.get("fileType"));
                    if (m.get("fileSize") != null) {
                        att.setFileSize(((Number) m.get("fileSize")).longValue());
                    }
                    att.setCloudinaryPublicId((String) m.get("cloudinaryPublicId"));
                    attachmentRepository.save(att);
                    if (saved.getAttachmentUrl() == null || saved.getAttachmentUrl().isBlank()) {
                        saved.setAttachmentUrl(att.getFileUrl());
                        assignmentRepository.save(saved);
                    }
                }
            }
        }

        return formatAssignment(saved, user);
    }

    @Transactional
    public Map<String, Object> updateAssignment(UserEntity user, UUID assignmentId, Map<String, Object> body) {
        AssignmentEntity assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found."));

        if (!canManageAssignment(user, assignment)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the instructor or administrator can update this assignment.");
        }

        if (body.get("title") != null) {
            String title = body.get("title").toString().trim();
            if (title.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Assignment title is required.");
            assignment.setTitle(title);
        }
        if (body.containsKey("instructions")) assignment.setInstructions((String) body.get("instructions"));
        if (body.containsKey("description")) assignment.setDescription((String) body.get("description"));

        if (body.get("maximumMarks") instanceof Number m) {
            assignment.setMaximumMarks(m.intValue());
            assignment.setPointsPossible(m.intValue());
        } else if (body.get("pointsPossible") instanceof Number p) {
            assignment.setMaximumMarks(p.intValue());
            assignment.setPointsPossible(p.intValue());
        }

        if (body.get("dueDate") != null) assignment.setDueDate(parseDateTime(body.get("dueDate").toString()));
        if (body.get("startDate") != null) assignment.setStartDate(parseDateTime(body.get("startDate").toString()));
        if (body.get("topic") != null) assignment.setTopic(body.get("topic").toString().trim());
        if (body.get("attachmentUrl") != null) assignment.setAttachmentUrl(body.get("attachmentUrl").toString().trim());
        if (body.get("allowLateSubmissions") != null) assignment.setAllowLateSubmissions(Boolean.TRUE.equals(body.get("allowLateSubmissions")));
        if (body.get("allowResubmission") != null) assignment.setAllowResubmission(Boolean.TRUE.equals(body.get("allowResubmission")));
        if (body.get("status") != null) assignment.setStatus(body.get("status").toString().toUpperCase(Locale.ROOT));

        assignment.setUpdatedAt(LocalDateTime.now());
        return formatAssignment(assignmentRepository.save(assignment), user);
    }

    @Transactional
    public void deleteAssignment(UserEntity user, UUID assignmentId) {
        AssignmentEntity assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found."));

        if (!canManageAssignment(user, assignment)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the instructor or administrator can delete this assignment.");
        }

        assignmentRepository.delete(assignment);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getInstructorAssignments(UserEntity instructor) {
        List<AssignmentEntity> list = assignmentRepository.findByInstructorIdOrderByCreatedAtDesc(instructor.getId());
        return list.stream().map(a -> formatAssignment(a, instructor)).collect(Collectors.toList());
    }

    /**
     * Students ONLY see published assignments belonging to their enrolled courses and batches!
     */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getStudentAssignments(UserEntity student) {
        if (student == null || student.getId() == null) return Collections.emptyList();

        List<EnrollmentEntity> enrollments = enrollmentRepository.findByStudentId(student.getId());
        List<UUID> batchIds = (enrollments != null) ? enrollments.stream()
                .map(EnrollmentEntity::getBatch)
                .filter(Objects::nonNull)
                .map(BatchEntity::getId)
                .filter(Objects::nonNull)
                .toList() : Collections.emptyList();

        List<UUID> courseIds = (enrollments != null) ? enrollments.stream()
                .map(EnrollmentEntity::getCourse)
                .filter(Objects::nonNull)
                .map(CourseEntity::getId)
                .filter(Objects::nonNull)
                .toList() : Collections.emptyList();

        Set<UUID> seen = new HashSet<>();
        List<AssignmentEntity> result = new ArrayList<>();

        if (!batchIds.isEmpty()) {
            try {
                for (AssignmentEntity a : assignmentRepository.findPublishedByBatchIdIn(batchIds)) {
                    if (a != null && a.getId() != null && seen.add(a.getId())) result.add(a);
                }
            } catch (Exception ignored) {}
        }
        if (!courseIds.isEmpty()) {
            try {
                for (AssignmentEntity a : assignmentRepository.findPublishedByCourseIdIn(courseIds)) {
                    if (a != null && a.getId() != null && seen.add(a.getId())) result.add(a);
                }
            } catch (Exception ignored) {}
        }

        // Also include classroom assignments for enrolled classrooms
        try {
            List<ClassroomMemberEntity> memberships = memberRepository.findByUserIdAndStatus(student.getId(), "ACTIVE");
            if (memberships != null) {
                for (ClassroomMemberEntity m : memberships) {
                    if (m != null && m.getClassroom() != null && m.getClassroom().getId() != null) {
                        List<AssignmentEntity> classAssignments = assignmentRepository.findByClassroomIdAndStatusOrderByDueDateAsc(m.getClassroom().getId(), "PUBLISHED");
                        if (classAssignments != null) {
                            for (AssignmentEntity a : classAssignments) {
                                if (a != null && a.getId() != null && seen.add(a.getId())) result.add(a);
                            }
                        }
                    }
                }
            }
        } catch (Exception ignored) {}

        return result.stream()
                .filter(Objects::nonNull)
                .map(a -> formatAssignment(a, student))
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getClassroomAssignments(UserEntity user, UUID classroomId, String topic) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));
        checkClassAccess(user, classroom);

        List<AssignmentEntity> list = (topic != null && !topic.isBlank())
                ? assignmentRepository.findByClassroomIdAndTopicOrderByCreatedAtDesc(classroomId, topic)
                : assignmentRepository.findByClassroomIdOrderByCreatedAtDesc(classroomId);

        return list.stream().map(a -> formatAssignment(a, user)).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getAssignmentDetails(UserEntity user, UUID assignmentId) {
        AssignmentEntity assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found."));

        Map<String, Object> result = formatAssignment(assignment, user);
        List<AssignmentAttachmentEntity> attachments = attachmentRepository.findByAssignmentIdOrderByUploadedAtAsc(assignmentId);
        result.put("attachments", attachments.stream().map(this::formatAttachment).collect(Collectors.toList()));

        boolean isTeacherOrAdmin = "admin".equalsIgnoreCase(user.getRole()) || canManageAssignment(user, assignment);

        if (isTeacherOrAdmin) {
            List<AssignmentSubmissionEntity> submissions = submissionRepository.findByAssignmentIdOrderBySubmittedAtAsc(assignmentId);
            result.put("submissions", submissions.stream().map(s -> {
                Map<String, Object> subMap = formatSubmission(s);
                gradeRepository.findBySubmissionId(s.getId()).ifPresent(g -> subMap.put("grade", formatGrade(g)));
                return subMap;
            }).collect(Collectors.toList()));
        } else {
            submissionRepository.findByAssignmentIdAndStudentId(assignmentId, user.getId()).ifPresent(sub -> {
                Map<String, Object> subMap = formatSubmission(sub);
                gradeRepository.findBySubmissionId(sub.getId()).ifPresent(g -> subMap.put("grade", formatGrade(g)));
                result.put("mySubmission", subMap);
            });
        }

        return result;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAssignmentSubmissions(UserEntity instructor, UUID assignmentId) {
        AssignmentEntity assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found."));

        if (!canManageAssignment(instructor, assignment)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied.");
        }

        List<AssignmentSubmissionEntity> submissions = submissionRepository.findByAssignmentIdOrderBySubmittedAtAsc(assignmentId);
        return submissions.stream().map(s -> {
            Map<String, Object> map = formatSubmission(s);
            gradeRepository.findBySubmissionId(s.getId()).ifPresent(g -> map.put("grade", formatGrade(g)));
            return map;
        }).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> submitAssignment(UserEntity student, UUID assignmentId, Map<String, Object> body) {
        AssignmentEntity assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found."));

        if (!"PUBLISHED".equalsIgnoreCase(assignment.getStatus())) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found.");
        }
        if (body == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Submission data is required.");

        LocalDateTime now = LocalDateTime.now();
        boolean isLate = assignment.getDueDate() != null && now.isAfter(assignment.getDueDate());

        if (isLate && !assignment.isAllowLateSubmissions()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "The deadline for this assignment has passed and late submissions are not allowed.");
        }

        Optional<AssignmentSubmissionEntity> existingSubmission = submissionRepository.findByAssignmentIdAndStudentId(assignmentId, student.getId());
        if (existingSubmission.isPresent()) {
            AssignmentSubmissionEntity existing = existingSubmission.get();
            if (!assignment.isAllowResubmission() && !"ASSIGNED".equalsIgnoreCase(existing.getStatus())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "This assignment has already been submitted and resubmission is disabled.");
            }
        }

        AssignmentSubmissionEntity submission = existingSubmission.orElseGet(() -> {
            AssignmentSubmissionEntity s = new AssignmentSubmissionEntity();
            s.setAssignment(assignment);
            s.setStudent(student);
            return s;
        });

        if (submission.getId() != null) {
            submission.setVersionNumber(submission.getVersionNumber() + 1);
        }

        submission.setSubmissionText((String) body.get("submissionText"));
        if (body.get("studentComments") != null) {
            submission.setStudentComments(body.get("studentComments").toString().trim());
        }
        if (body.get("submissionFileUrl") != null) {
            submission.setSubmissionFileUrl(body.get("submissionFileUrl").toString().trim());
        }

        submission.setStatus(isLate ? "Late" : "Submitted");
        submission.setSubmittedAt(now);
        submission.setUpdatedAt(now);

        AssignmentSubmissionEntity savedSubmission = submissionRepository.save(submission);

        // Save attachments if provided
        if (body.get("attachments") instanceof List<?> list) {
            for (Object obj : list) {
                if (obj instanceof Map<?, ?> m) {
                    AssignmentAttachmentEntity att = new AssignmentAttachmentEntity();
                    att.setSubmission(savedSubmission);
                    att.setFileName((String) m.get("fileName"));
                    att.setFileUrl(requireFileUrl(m.get("fileUrl")));
                    att.setFileType((String) m.get("fileType"));
                    if (m.get("fileSize") != null) {
                        att.setFileSize(((Number) m.get("fileSize")).longValue());
                    }
                    att.setCloudinaryPublicId((String) m.get("cloudinaryPublicId"));
                    attachmentRepository.save(att);
                    if (savedSubmission.getSubmissionFileUrl() == null || savedSubmission.getSubmissionFileUrl().isBlank()) {
                        savedSubmission.setSubmissionFileUrl(att.getFileUrl());
                        submissionRepository.save(savedSubmission);
                    }
                }
            }
        }

        Map<String, Object> res = formatSubmission(savedSubmission);
        res.put("message", isLate ? "Assignment submitted late." : "Assignment submitted successfully!");
        return res;
    }

    @Transactional
    public Map<String, Object> evaluateSubmission(UserEntity instructor, UUID submissionId, Map<String, Object> body) {
        AssignmentSubmissionEntity submission = submissionRepository.findById(submissionId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Submission not found."));

        if (!canManageAssignment(instructor, submission.getAssignment())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the instructor can evaluate this submission.");
        }

        Object scoreObj = body.get("marksObtained") != null ? body.get("marksObtained") : body.get("score");
        if (scoreObj == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Marks obtained is required.");
        }

        BigDecimal marks = new BigDecimal(scoreObj.toString());
        int maxMarks = submission.getAssignment().getMaximumMarks();
        if (marks.compareTo(BigDecimal.ZERO) < 0 || marks.compareTo(BigDecimal.valueOf(maxMarks)) > 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Marks must be between 0 and " + maxMarks);
        }

        submission.setMarksObtained(marks);
        String feedback = body.get("instructorFeedback") != null ? body.get("instructorFeedback").toString() : (String) body.get("feedback");
        submission.setInstructorFeedback(feedback);

        if (body.get("evaluatedFileUrl") != null) {
            submission.setEvaluatedFileUrl(body.get("evaluatedFileUrl").toString().trim());
        }

        submission.setStatus("Evaluated");
        submission.setEvaluatedAt(LocalDateTime.now());
        submission.setUpdatedAt(LocalDateTime.now());
        AssignmentSubmissionEntity savedSubmission = submissionRepository.save(submission);

        // Also sync with GradeEntity
        GradeEntity grade = gradeRepository.findBySubmissionId(submissionId).orElseGet(() -> {
            GradeEntity g = new GradeEntity();
            g.setSubmission(savedSubmission);
            return g;
        });
        grade.setScore(marks);
        grade.setFeedback(feedback);
        grade.setGradedBy(instructor);
        grade.setGradedAt(LocalDateTime.now());
        grade.setReturned(true);
        gradeRepository.save(grade);

        Map<String, Object> result = formatSubmission(savedSubmission);
        result.put("message", "Result published successfully.");
        return result;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getStudentResults(UserEntity student) {
        if (student == null || student.getId() == null) return Collections.emptyList();

        List<AssignmentSubmissionEntity> submissions = submissionRepository.findByStudentIdOrderBySubmittedAtDesc(student.getId());
        List<Map<String, Object>> results = new ArrayList<>();
        if (submissions == null) return results;

        for (AssignmentSubmissionEntity s : submissions) {
            if (s == null) continue;
            String status = s.getStatus() != null ? s.getStatus() : "";
            if ("Evaluated".equalsIgnoreCase(status) || s.getMarksObtained() != null || "GRADED".equalsIgnoreCase(status) || "RETURNED".equalsIgnoreCase(status)) {
                Map<String, Object> r = new LinkedHashMap<>();
                r.put("submissionId", s.getId() != null ? s.getId().toString() : "");

                AssignmentEntity a = s.getAssignment();
                r.put("assignmentId", a != null && a.getId() != null ? a.getId().toString() : "");
                r.put("assignmentTitle", a != null && a.getTitle() != null ? a.getTitle() : "Assignment");

                String courseName = "General";
                if (a != null && a.getCourse() != null && a.getCourse().getCourseName() != null) {
                    courseName = a.getCourse().getCourseName();
                } else if (a != null && a.getClassroom() != null && a.getClassroom().getName() != null) {
                    courseName = a.getClassroom().getName();
                }
                r.put("courseName", courseName);

                Integer maxMarks = a != null && a.getMaximumMarks() != null ? a.getMaximumMarks() : (a != null ? a.getPointsPossible() : 100);
                r.put("totalMarks", maxMarks);
                r.put("maximumMarks", maxMarks);
                r.put("marksObtained", s.getMarksObtained());
                r.put("score", s.getMarksObtained());
                r.put("instructorFeedback", s.getInstructorFeedback() != null ? s.getInstructorFeedback() : "");
                r.put("feedback", s.getInstructorFeedback() != null ? s.getInstructorFeedback() : "");

                String evalDate = s.getEvaluatedAt() != null ? s.getEvaluatedAt().toString()
                        : (s.getUpdatedAt() != null ? s.getUpdatedAt().toString()
                        : (s.getSubmittedAt() != null ? s.getSubmittedAt().toString() : ""));
                r.put("evaluationDate", evalDate);
                r.put("evaluatedFileUrl", s.getEvaluatedFileUrl());
                r.put("submissionFileUrl", s.getSubmissionFileUrl());
                results.add(r);
            }
        }
        return results;
    }

    @Transactional
    public Map<String, Object> gradeSubmission(UserEntity teacher, UUID submissionId, Map<String, Object> body) {
        return evaluateSubmission(teacher, submissionId, body);
    }

    @Transactional
    public Map<String, Object> unsubmitAssignment(UserEntity student, UUID assignmentId) {
        AssignmentSubmissionEntity submission = submissionRepository
                .findByAssignmentIdAndStudentId(assignmentId, student.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No submission found to unsubmit."));

        if ("Evaluated".equalsIgnoreCase(submission.getStatus()) || "GRADED".equals(submission.getStatus()) || "RETURNED".equals(submission.getStatus())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cannot unsubmit an assignment that has already been evaluated.");
        }

        submission.setStatus("ASSIGNED");
        attachmentRepository.deleteAll(attachmentRepository.findBySubmissionIdOrderByUploadedAtAsc(submission.getId()));
        AssignmentSubmissionEntity saved = submissionRepository.save(submission);
        return Map.of("status", "ASSIGNED", "message", "Assignment unsubmitted. You can now update your work and turn it in again.");
    }

    @Transactional
    public void deleteAttachment(UserEntity user, UUID attachmentId) {
        AssignmentAttachmentEntity att = attachmentRepository.findById(attachmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Attachment not found."));
        attachmentRepository.delete(att);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getStudentTodoList(UserEntity student) {
        List<ClassroomMemberEntity> memberships = memberRepository.findByUserIdAndStatus(student.getId(), "ACTIVE").stream()
                .filter(m -> "STUDENT".equalsIgnoreCase(m.getRole())).collect(Collectors.toList());
        List<UUID> classroomIds = memberships.stream().map(m -> m.getClassroom().getId()).collect(Collectors.toList());

        List<Map<String, Object>> assigned = new ArrayList<>();
        List<Map<String, Object>> missing = new ArrayList<>();
        List<Map<String, Object>> done = new ArrayList<>();

        if (!classroomIds.isEmpty()) {
            LocalDateTime now = LocalDateTime.now();
            List<AssignmentEntity> allAssignments = assignmentRepository.findByClassroomIdInOrderByDueDateAsc(classroomIds);

            for (AssignmentEntity a : allAssignments) {
                if (!"PUBLISHED".equalsIgnoreCase(a.getStatus())) continue;
                Map<String, Object> aMap = formatAssignment(a, student);
                if (a.getClassroom() != null) {
                    aMap.put("classroomName", a.getClassroom().getName());
                    aMap.put("classroomThemeColor", a.getClassroom().getThemeColor());
                }

                String subStatus = (String) aMap.get("submissionStatus");
                if ("TURNED_IN".equals(subStatus) || "GRADED".equals(subStatus) || "RETURNED".equals(subStatus) || "LATE".equals(subStatus) || "Evaluated".equals(subStatus) || "Submitted".equals(subStatus)) {
                    done.add(aMap);
                } else if (a.getDueDate() != null && now.isAfter(a.getDueDate())) {
                    missing.add(aMap);
                } else {
                    assigned.add(aMap);
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("assigned", assigned);
        result.put("missing", missing);
        result.put("done", done);
        return result;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getClassGradebook(UserEntity user, UUID classroomId) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));

        checkTeacherOrAdmin(user, classroom);

        List<AssignmentEntity> assignments = assignmentRepository.findByClassroomIdOrderByCreatedAtDesc(classroomId);
        List<ClassroomMemberEntity> studentMembers = memberRepository.findByClassroomIdAndStatus(classroomId, "ACTIVE")
                .stream().filter(m -> "STUDENT".equalsIgnoreCase(m.getRole())).collect(Collectors.toList());

        List<Map<String, Object>> studentGrades = new ArrayList<>();
        for (ClassroomMemberEntity member : studentMembers) {
            UserEntity student = member.getUser();
            Map<String, Object> row = new HashMap<>();
            row.put("studentId", student.getId());
            row.put("studentName", student.getName());
            row.put("studentEmail", student.getEmail());

            Map<String, Object> assignmentScores = new HashMap<>();
            BigDecimal totalScore = BigDecimal.ZERO;
            int totalPossible = 0;

            for (AssignmentEntity a : assignments) {
                Optional<AssignmentSubmissionEntity> subOpt = submissionRepository.findByAssignmentIdAndStudentId(a.getId(), student.getId());
                if (subOpt.isPresent()) {
                    Optional<GradeEntity> gradeOpt = gradeRepository.findBySubmissionId(subOpt.get().getId());
                    if (gradeOpt.isPresent()) {
                        BigDecimal sc = gradeOpt.get().getScore();
                        assignmentScores.put(a.getId().toString(), sc);
                        totalScore = totalScore.add(sc);
                    } else if (subOpt.get().getMarksObtained() != null) {
                        assignmentScores.put(a.getId().toString(), subOpt.get().getMarksObtained());
                        totalScore = totalScore.add(subOpt.get().getMarksObtained());
                    } else {
                        assignmentScores.put(a.getId().toString(), subOpt.get().getStatus());
                    }
                } else {
                    assignmentScores.put(a.getId().toString(), "MISSING");
                }
                totalPossible += a.getPointsPossible();
            }

            row.put("scores", assignmentScores);
            row.put("totalScore", totalScore);
            row.put("totalPossible", totalPossible);
            row.put("percentage", totalPossible > 0 ? totalScore.doubleValue() / totalPossible * 100 : 0.0);
            studentGrades.add(row);
        }

        return Map.of(
                "classroomId", classroomId,
                "assignments", assignments.stream().map(a -> Map.of("id", a.getId(), "title", a.getTitle(), "pointsPossible", a.getPointsPossible())).collect(Collectors.toList()),
                "gradebook", studentGrades
        );
    }

    private boolean canManageAssignment(UserEntity user, AssignmentEntity assignment) {
        if ("admin".equalsIgnoreCase(user.getRole())) return true;
        if (assignment.getInstructor() != null && assignment.getInstructor().getId().equals(user.getId())) return true;
        if (assignment.getCreatedBy() != null && assignment.getCreatedBy().getId().equals(user.getId())) return true;
        if (assignment.getClassroom() != null) {
            return canManage(user, assignment.getClassroom());
        }
        return false;
    }

    private boolean canManage(UserEntity user, ClassroomEntity classroom) {
        if ("admin".equalsIgnoreCase(user.getRole())) return true;
        if (classroom.getCreator().getId().equals(user.getId())) return true;
        return memberRepository.findByClassroomIdAndUserId(classroom.getId(), user.getId())
                .map(m -> "ACTIVE".equalsIgnoreCase(m.getStatus()) && ("TEACHER".equalsIgnoreCase(m.getRole()) || "CO_TEACHER".equalsIgnoreCase(m.getRole())))
                .orElse(false);
    }

    private void checkTeacherOrAdmin(UserEntity user, ClassroomEntity classroom) {
        if (!canManage(user, classroom)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only teachers or administrators can perform this action.");
        }
    }

    private void checkClassAccess(UserEntity user, ClassroomEntity classroom) {
        if ("admin".equalsIgnoreCase(user.getRole())) return;
        if ("student".equalsIgnoreCase(user.getRole())) { checkStudentAccess(user, classroom); return; }
        if ("teacher".equalsIgnoreCase(user.getRole()) || "instructor".equalsIgnoreCase(user.getRole())) { checkTeacherOrAdmin(user, classroom); return; }
        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have access to this class.");
    }

    private void checkStudentAccess(UserEntity student, ClassroomEntity classroom) {
        if (!isActiveStudent(student, classroom)) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "This assignment is not assigned to your class.");
    }

    private boolean isActiveStudent(UserEntity student, ClassroomEntity classroom) {
        return memberRepository.findByClassroomIdAndUserId(classroom.getId(), student.getId())
                .filter(m -> "ACTIVE".equalsIgnoreCase(m.getStatus()) && "STUDENT".equalsIgnoreCase(m.getRole())).isPresent();
    }

    public Map<String, Object> formatAssignment(AssignmentEntity a, UserEntity user) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", a.getId().toString());
        map.put("title", a.getTitle());
        map.put("description", a.getDescription() != null ? a.getDescription() : a.getInstructions());
        map.put("instructions", a.getInstructions());
        map.put("pointsPossible", a.getPointsPossible());
        map.put("maximumMarks", a.getMaximumMarks());
        map.put("dueDate", a.getDueDate() != null ? a.getDueDate().toString() : null);
        map.put("startDate", a.getStartDate() != null ? a.getStartDate().toString() : null);
        map.put("topic", a.getTopic());
        map.put("attachmentUrl", a.getAttachmentUrl());
        map.put("allowLateSubmissions", a.isAllowLateSubmissions());
        map.put("allowResubmission", a.isAllowResubmission());
        map.put("allowedFileTypes", a.getAllowedFileTypes());
        map.put("status", a.getStatus());
        map.put("createdAt", a.getCreatedAt() != null ? a.getCreatedAt().toString() : null);

        if (a.getClassroom() != null) {
            map.put("classroomId", a.getClassroom().getId().toString());
            map.put("classroomName", a.getClassroom().getName());
            map.put("subject", a.getClassroom().getSubject() != null ? a.getClassroom().getSubject() : "");
        }
        if (a.getCourse() != null) {
            map.put("courseId", a.getCourse().getId().toString());
            map.put("courseName", a.getCourse().getCourseName());
            if (!map.containsKey("subject") || map.get("subject").toString().isEmpty()) {
                map.put("subject", a.getCourse().getCourseName());
            }
        }
        if (a.getBatch() != null) {
            map.put("batchId", a.getBatch().getId().toString());
            map.put("batchName", a.getBatch().getBatchName());
        }
        if (a.getInstructor() != null) {
            map.put("instructorId", a.getInstructor().getId().toString());
            map.put("instructorName", a.getInstructor().getName());
            map.put("createdByName", a.getInstructor().getName());
        } else if (a.getCreatedBy() != null) {
            map.put("instructorId", a.getCreatedBy().getId().toString());
            map.put("instructorName", a.getCreatedBy().getName());
            map.put("createdByName", a.getCreatedBy().getName());
        }

        if (user != null && "student".equalsIgnoreCase(user.getRole())) {
            submissionRepository.findByAssignmentIdAndStudentId(a.getId(), user.getId()).ifPresentOrElse(sub -> {
                map.put("submissionStatus", sub.getStatus());
                map.put("submittedAt", sub.getSubmittedAt() != null ? sub.getSubmittedAt().toString() : null);
                map.put("submissionFileUrl", sub.getSubmissionFileUrl());
                map.put("studentComments", sub.getStudentComments());
                map.put("marksObtained", sub.getMarksObtained());
                map.put("myScore", sub.getMarksObtained());
                map.put("score", sub.getMarksObtained());
                map.put("instructorFeedback", sub.getInstructorFeedback());
                map.put("feedback", sub.getInstructorFeedback());
                map.put("evaluatedFileUrl", sub.getEvaluatedFileUrl());
                gradeRepository.findBySubmissionId(sub.getId()).ifPresent(g -> {
                    if (sub.getMarksObtained() == null) {
                        map.put("marksObtained", g.getScore());
                        map.put("myScore", g.getScore());
                        map.put("score", g.getScore());
                    }
                    if (sub.getInstructorFeedback() == null) {
                        map.put("instructorFeedback", g.getFeedback());
                        map.put("feedback", g.getFeedback());
                    }
                    map.put("isReturned", g.isReturned());
                });
            }, () -> {
                boolean overdue = a.getDueDate() != null && LocalDateTime.now().isAfter(a.getDueDate());
                map.put("submissionStatus", overdue ? "Late" : "New");
            });
        } else {
            long turnedIn = submissionRepository.countByAssignmentIdAndStatus(a.getId(), "Submitted")
                    + submissionRepository.countByAssignmentIdAndStatus(a.getId(), "TURNED_IN")
                    + submissionRepository.countByAssignmentIdAndStatus(a.getId(), "Late")
                    + submissionRepository.countByAssignmentIdAndStatus(a.getId(), "LATE");
            long evaluated = submissionRepository.countByAssignmentIdAndStatus(a.getId(), "Evaluated")
                    + submissionRepository.countByAssignmentIdAndStatus(a.getId(), "GRADED")
                    + submissionRepository.countByAssignmentIdAndStatus(a.getId(), "RETURNED");
            map.put("turnedInCount", turnedIn);
            map.put("evaluatedCount", evaluated);
            map.put("gradedCount", evaluated);
        }

        return map;
    }

    public Map<String, Object> formatSubmission(AssignmentSubmissionEntity s) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", s.getId().toString());
        map.put("assignmentId", s.getAssignment().getId().toString());
        map.put("assignmentTitle", s.getAssignment().getTitle());
        map.put("maximumMarks", s.getAssignment().getMaximumMarks());
        map.put("studentId", s.getStudent().getId().toString());
        map.put("studentCode", s.getStudent().getRollNumber() != null ? s.getStudent().getRollNumber() : s.getStudent().getUserId());
        map.put("studentName", s.getStudent().getName());
        map.put("studentEmail", s.getStudent().getEmail());
        map.put("submissionText", s.getSubmissionText());
        map.put("submissionFileUrl", s.getSubmissionFileUrl());
        map.put("studentComments", s.getStudentComments());
        map.put("status", s.getStatus());
        map.put("marksObtained", s.getMarksObtained());
        map.put("score", s.getMarksObtained());
        map.put("instructorFeedback", s.getInstructorFeedback());
        map.put("feedback", s.getInstructorFeedback());
        map.put("evaluatedFileUrl", s.getEvaluatedFileUrl());
        map.put("evaluatedAt", s.getEvaluatedAt() != null ? s.getEvaluatedAt().toString() : null);
        map.put("versionNumber", s.getVersionNumber());
        map.put("submittedAt", s.getSubmittedAt() != null ? s.getSubmittedAt().toString() : null);

        List<AssignmentAttachmentEntity> attachments = attachmentRepository.findBySubmissionIdOrderByUploadedAtAsc(s.getId());
        map.put("attachments", attachments.stream().map(this::formatAttachment).collect(Collectors.toList()));
        return map;
    }

    private Map<String, Object> formatAttachment(AssignmentAttachmentEntity att) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", att.getId().toString());
        map.put("fileName", att.getFileName());
        map.put("fileUrl", att.getFileUrl());
        map.put("fileType", att.getFileType());
        map.put("fileSize", att.getFileSize());
        map.put("cloudinaryPublicId", att.getCloudinaryPublicId());
        map.put("uploadedAt", att.getUploadedAt().toString());
        return map;
    }

    private Map<String, Object> formatGrade(GradeEntity g) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", g.getId().toString());
        map.put("submissionId", g.getSubmission().getId().toString());
        map.put("score", g.getScore());
        map.put("marksObtained", g.getScore());
        map.put("feedback", g.getFeedback());
        map.put("instructorFeedback", g.getFeedback());
        map.put("gradedByName", g.getGradedBy().getName());
        map.put("gradedAt", g.getGradedAt().toString());
        map.put("isReturned", g.isReturned());
        return map;
    }

    private String requireFileUrl(Object value) {
        String fileUrl = Objects.toString(value, "").trim();
        try {
            java.net.URI uri = java.net.URI.create(fileUrl);
            if (!"https".equalsIgnoreCase(uri.getScheme()) || uri.getHost() == null) {
                throw new IllegalArgumentException();
            }
            return fileUrl;
        } catch (IllegalArgumentException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Attachment must have a valid HTTPS URL.");
        }
    }

    private LocalDateTime parseDateTime(String text) {
        try {
            return LocalDateTime.parse(text, DateTimeFormatter.ISO_DATE_TIME);
        } catch (Exception ex) {
            try {
                return LocalDateTime.parse(text, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            } catch (Exception ex2) {
                try {
                    return LocalDate.parse(text).atStartOfDay();
                } catch (Exception invalid) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Date must be a valid ISO date and time: " + text);
                }
            }
        }
    }
}
