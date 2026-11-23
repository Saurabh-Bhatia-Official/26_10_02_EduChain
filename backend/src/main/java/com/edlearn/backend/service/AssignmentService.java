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
    private final CloudinaryService cloudinaryService;

    public AssignmentService(AssignmentRepository assignmentRepository,
                             AssignmentSubmissionRepository submissionRepository,
                             AssignmentAttachmentRepository attachmentRepository,
                             GradeRepository gradeRepository,
                             ClassroomRepository classroomRepository,
                             ClassroomMemberRepository memberRepository,
                             CloudinaryService cloudinaryService) {
        this.assignmentRepository = assignmentRepository;
        this.submissionRepository = submissionRepository;
        this.attachmentRepository = attachmentRepository;
        this.gradeRepository = gradeRepository;
        this.classroomRepository = classroomRepository;
        this.memberRepository = memberRepository;
        this.cloudinaryService = cloudinaryService;
    }

    public Map<String, Object> uploadAssignmentFile(UserEntity user, UUID classroomId, String purpose, MultipartFile file) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));
        if ("ASSIGNMENT".equalsIgnoreCase(purpose)) {
            checkTeacherOrAdmin(user, classroom);
        } else if ("SUBMISSION".equalsIgnoreCase(purpose)) {
            if (!"student".equalsIgnoreCase(user.getRole()) || !isActiveStudent(user, classroom)) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only enrolled students can upload submission files for this class.");
            }
        } else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Upload purpose must be ASSIGNMENT or SUBMISSION.");
        }
        if (file == null || file.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Choose a non-empty file to upload.");
        if (file.getSize() > 25L * 1024 * 1024) throw new ResponseStatusException(HttpStatus.PAYLOAD_TOO_LARGE, "Assignment files must be 25 MB or smaller.");
        String fileName = Objects.toString(file.getOriginalFilename(), "").toLowerCase(Locale.ROOT);
        Set<String> allowedExtensions = Set.of("pdf", "doc", "docx", "odt", "rtf", "txt", "png", "jpg", "jpeg", "gif", "webp", "ppt", "pptx", "xls", "xlsx", "csv", "zip");
        int extensionIndex = fileName.lastIndexOf('.');
        if (extensionIndex < 0 || !allowedExtensions.contains(fileName.substring(extensionIndex + 1))) {
            throw new ResponseStatusException(HttpStatus.UNSUPPORTED_MEDIA_TYPE, "Unsupported file type. Upload a document, PDF, image, spreadsheet, or archive.");
        }
        String folder = "educhain/assignments/" + classroomId + "/" + purpose.toLowerCase(Locale.ROOT);
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
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));

        checkTeacherOrAdmin(user, classroom);

        String title = (String) body.get("title");
        if (title == null || title.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Assignment title is required.");
        }

        AssignmentEntity assignment = new AssignmentEntity();
        assignment.setClassroom(classroom);
        assignment.setTitle(title.trim());
        assignment.setInstructions((String) body.get("instructions"));
        
        if (body.get("pointsPossible") != null) {
            assignment.setPointsPossible(((Number) body.get("pointsPossible")).intValue());
        }
        if (assignment.getPointsPossible() <= 0) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Maximum marks must be positive.");
        if (assignment.getPointsPossible() <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Points possible must be greater than zero.");
        }
        
        if (body.get("dueDate") != null) {
            assignment.setDueDate(parseDateTime((String) body.get("dueDate")));
        }

        if (body.get("topic") != null && !((String) body.get("topic")).isBlank()) {
            assignment.setTopic(((String) body.get("topic")).trim());
        }

        if (body.get("allowLateSubmissions") != null) {
            assignment.setAllowLateSubmissions(Boolean.TRUE.equals(body.get("allowLateSubmissions")));
        }

        String status = body.get("status") == null ? "PUBLISHED" : body.get("status").toString().toUpperCase(Locale.ROOT);
        if (!Set.of("DRAFT", "PUBLISHED").contains(status)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Assignment status must be DRAFT or PUBLISHED.");
        assignment.setStatus(status);
        assignment.setCreatedBy(user);
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
                }
            }
        }

        return formatAssignment(saved, user);
    }

    @Transactional
    public Map<String, Object> updateAssignment(UserEntity user, UUID assignmentId, Map<String, Object> body) {
        AssignmentEntity assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found."));
        checkTeacherOrAdmin(user, assignment.getClassroom());
        if (body.get("title") != null) {
            String title = body.get("title").toString().trim();
            if (title.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Assignment title is required.");
            assignment.setTitle(title);
        }
        if (body.containsKey("instructions")) assignment.setInstructions((String) body.get("instructions"));
        if (body.get("pointsPossible") instanceof Number n) assignment.setPointsPossible(n.intValue());
        if (assignment.getPointsPossible() <= 0) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Maximum marks must be positive.");
        if (assignment.getPointsPossible() <= 0) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Points possible must be greater than zero.");
        if (body.containsKey("dueDate")) assignment.setDueDate(body.get("dueDate") == null ? null : parseDateTime(body.get("dueDate").toString()));
        if (body.containsKey("topic")) assignment.setTopic(body.get("topic") == null ? "General" : body.get("topic").toString().trim());
        if (body.get("allowLateSubmissions") != null) assignment.setAllowLateSubmissions(Boolean.TRUE.equals(body.get("allowLateSubmissions")));
        if (body.get("status") != null) {
            String status = body.get("status").toString().toUpperCase(Locale.ROOT);
            if (!Set.of("DRAFT", "PUBLISHED").contains(status)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Assignment status must be Draft or Published.");
            assignment.setStatus(status);
        }
        assignment.setUpdatedAt(LocalDateTime.now());
        if (body.get("attachments") instanceof List<?> list) {
            for (Object obj : list) if (obj instanceof Map<?, ?> m) {
                AssignmentAttachmentEntity att = new AssignmentAttachmentEntity();
                att.setAssignment(assignment); att.setFileName(Objects.toString(m.get("fileName"), "file"));
                att.setFileUrl(requireFileUrl(m.get("fileUrl"))); att.setFileType((String) m.get("fileType"));
                if (m.get("fileSize") instanceof Number n) att.setFileSize(n.longValue());
                att.setCloudinaryPublicId((String) m.get("cloudinaryPublicId")); attachmentRepository.save(att);
            }
        }
        return formatAssignment(assignmentRepository.save(assignment), user);
    }

    @Transactional
    public void deleteAssignment(UserEntity user, UUID assignmentId) {
        AssignmentEntity assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found."));
        checkTeacherOrAdmin(user, assignment.getClassroom());
        List<AssignmentSubmissionEntity> submissions = submissionRepository.findByAssignmentIdOrderBySubmittedAtAsc(assignmentId);
        for (AssignmentSubmissionEntity submission : submissions) {
            gradeRepository.findBySubmissionId(submission.getId()).ifPresent(gradeRepository::delete);
            attachmentRepository.deleteAll(attachmentRepository.findBySubmissionIdOrderByUploadedAtAsc(submission.getId()));
        }
        attachmentRepository.deleteAll(attachmentRepository.findByAssignmentIdOrderByUploadedAtAsc(assignmentId));
        submissionRepository.deleteAll(submissions);
        assignmentRepository.delete(assignment);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getClassroomAssignments(UserEntity user, UUID classroomId, String topic) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));
        checkClassAccess(user, classroom);

        List<AssignmentEntity> list;
        if (topic != null && !topic.trim().isEmpty()) {
            list = assignmentRepository.findByClassroomIdAndTopicOrderByCreatedAtDesc(classroomId, topic.trim());
        } else {
            list = assignmentRepository.findByClassroomIdOrderByCreatedAtDesc(classroomId);
        }

        return list.stream().filter(a -> canManage(user, classroom) || "PUBLISHED".equalsIgnoreCase(a.getStatus()))
                .map(a -> formatAssignment(a, user)).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getAssignmentDetails(UserEntity user, UUID assignmentId) {
        AssignmentEntity assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found."));
        checkClassAccess(user, assignment.getClassroom());
        if (!canManage(user, assignment.getClassroom()) && !"PUBLISHED".equalsIgnoreCase(assignment.getStatus()))
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found.");

        Map<String, Object> result = formatAssignment(assignment, user);
        
        // Include teacher attachments
        List<AssignmentAttachmentEntity> attachments = attachmentRepository.findByAssignmentIdOrderByUploadedAtAsc(assignmentId);
        result.put("attachments", attachments.stream().map(this::formatAttachment).collect(Collectors.toList()));

        boolean isTeacher = canManage(user, assignment.getClassroom());
        if (isTeacher) {
            // Teacher sees all student submissions
            List<AssignmentSubmissionEntity> submissions = submissionRepository.findByAssignmentIdOrderBySubmittedAtAsc(assignmentId);
            result.put("submissions", submissions.stream().map(s -> {
                Map<String, Object> subMap = formatSubmission(s);
                gradeRepository.findBySubmissionId(s.getId()).ifPresent(g -> subMap.put("grade", formatGrade(g)));
                return subMap;
            }).collect(Collectors.toList()));
        } else {
            // Student sees only their own submission and returned grade
            submissionRepository.findByAssignmentIdAndStudentId(assignmentId, user.getId()).ifPresent(sub -> {
                Map<String, Object> subMap = formatSubmission(sub);
                gradeRepository.findBySubmissionId(sub.getId()).ifPresent(g -> subMap.put("grade", formatGrade(g)));
                result.put("mySubmission", subMap);
            });
        }

        return result;
    }

    @Transactional
    public Map<String, Object> submitAssignment(UserEntity student, UUID assignmentId, Map<String, Object> body) {
        AssignmentEntity assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found."));

        checkStudentAccess(student, assignment.getClassroom());
        if (!"PUBLISHED".equalsIgnoreCase(assignment.getStatus())) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Assignment not found.");
        if (body == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Submission data is required.");

        LocalDateTime now = LocalDateTime.now();
        boolean isLate = assignment.getDueDate() != null && now.isAfter(assignment.getDueDate());

        if (isLate && !assignment.isAllowLateSubmissions()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "The deadline for this assignment has passed and late submissions are not allowed.");
        }

        Optional<AssignmentSubmissionEntity> existingSubmission = submissionRepository.findByAssignmentIdAndStudentId(assignmentId, student.getId());
        if (existingSubmission.isPresent() && !"ASSIGNED".equalsIgnoreCase(existingSubmission.get().getStatus())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "This assignment has already been submitted. Unsubmit it before making changes.");
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
        submission.setStatus(isLate ? "LATE" : "TURNED_IN");
        submission.setSubmittedAt(now);

        AssignmentSubmissionEntity savedSubmission = submissionRepository.save(submission);

        // Save student attachments if provided
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
                }
            }
        }

        Map<String, Object> res = formatSubmission(savedSubmission);
        res.put("message", isLate ? "Assignment submitted late." : "Assignment turned in successfully!");
        return res;
    }

    @Transactional
    public Map<String, Object> gradeSubmission(UserEntity teacher, UUID submissionId, Map<String, Object> body) {
        AssignmentSubmissionEntity submission = submissionRepository.findById(submissionId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Submission not found."));

        checkTeacherOrAdmin(teacher, submission.getAssignment().getClassroom());

        Object scoreObj = body.get("score");
        if (scoreObj == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Score is required.");
        }

        BigDecimal score = new BigDecimal(scoreObj.toString());
        if (score.compareTo(BigDecimal.ZERO) < 0 || score.compareTo(BigDecimal.valueOf(submission.getAssignment().getPointsPossible())) > 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Score must be between 0 and " + submission.getAssignment().getPointsPossible());
        }

        GradeEntity grade = gradeRepository.findBySubmissionId(submissionId).orElseGet(() -> {
            GradeEntity g = new GradeEntity();
            g.setSubmission(submission);
            return g;
        });

        grade.setScore(score);
        grade.setFeedback((String) body.get("feedback"));
        grade.setGradedBy(teacher);
        grade.setGradedAt(LocalDateTime.now());
        grade.setReturned(Boolean.TRUE.equals(body.get("isReturned")));

        GradeEntity savedGrade = gradeRepository.save(grade);

        submission.setStatus(savedGrade.isReturned() ? "RETURNED" : "GRADED");
        submissionRepository.save(submission);

        return formatGrade(savedGrade);
    }

    @Transactional
    public Map<String, Object> unsubmitAssignment(UserEntity student, UUID assignmentId) {
        AssignmentSubmissionEntity submission = submissionRepository
                .findByAssignmentIdAndStudentId(assignmentId, student.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No submission found to unsubmit."));

        checkStudentAccess(student, submission.getAssignment().getClassroom());

        if ("GRADED".equals(submission.getStatus()) || "RETURNED".equals(submission.getStatus())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cannot unsubmit an assignment that has already been graded or returned.");
        }

        submission.setStatus("ASSIGNED");
        attachmentRepository.deleteAll(attachmentRepository.findBySubmissionIdOrderByUploadedAtAsc(submission.getId()));
        AssignmentSubmissionEntity saved = submissionRepository.save(submission);

        Map<String, Object> res = formatSubmission(saved);
        res.put("message", "Assignment unsubmitted. You can now edit attachments and resubmit.");
        return res;
    }

    @Transactional
    public void deleteAttachment(UserEntity user, UUID attachmentId) {
        AssignmentAttachmentEntity att = attachmentRepository.findById(attachmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Attachment not found."));

        if (att.getSubmission() != null) {
            if (!att.getSubmission().getStudent().getId().equals(user.getId()) && !"admin".equalsIgnoreCase(user.getRole())) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You cannot delete another student's attachment.");
            }
            if ("student".equalsIgnoreCase(user.getRole())) checkStudentAccess(user, att.getSubmission().getAssignment().getClassroom());
        } else if (att.getAssignment() != null) {
            checkTeacherOrAdmin(user, att.getAssignment().getClassroom());
        }

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
                aMap.put("classroomName", a.getClassroom().getName());
                aMap.put("classroomThemeColor", a.getClassroom().getThemeColor());

                String subStatus = (String) aMap.get("submissionStatus");
                if ("TURNED_IN".equals(subStatus) || "GRADED".equals(subStatus) || "RETURNED".equals(subStatus) || "LATE".equals(subStatus)) {
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
        if ("teacher".equalsIgnoreCase(user.getRole())) { checkTeacherOrAdmin(user, classroom); return; }
        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have access to this class.");
    }

    private void checkStudentAccess(UserEntity student, ClassroomEntity classroom) {
        if (!isActiveStudent(student, classroom)) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "This assignment is not assigned to your class.");
    }

    private boolean isActiveStudent(UserEntity student, ClassroomEntity classroom) {
        return memberRepository.findByClassroomIdAndUserId(classroom.getId(), student.getId())
                .filter(m -> "ACTIVE".equalsIgnoreCase(m.getStatus()) && "STUDENT".equalsIgnoreCase(m.getRole())).isPresent();
    }

    private Map<String, Object> formatAssignment(AssignmentEntity a, UserEntity user) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", a.getId());
        map.put("classroomId", a.getClassroom().getId());
        map.put("classroomName", a.getClassroom().getName());
        map.put("subject", a.getClassroom().getSubject() != null ? a.getClassroom().getSubject() : "");
        map.put("title", a.getTitle());
        map.put("instructions", a.getInstructions());
        map.put("pointsPossible", a.getPointsPossible());
        map.put("points", a.getPointsPossible());
        map.put("dueDate", a.getDueDate() != null ? a.getDueDate().toString() : null);
        map.put("topic", a.getTopic());
        map.put("allowLateSubmissions", a.isAllowLateSubmissions());
        map.put("status", a.getStatus());
        map.put("createdByName", a.getCreatedBy().getName());
        map.put("createdAt", a.getCreatedAt().toString());

        if ("student".equalsIgnoreCase(user.getRole())) {
            submissionRepository.findByAssignmentIdAndStudentId(a.getId(), user.getId()).ifPresentOrElse(sub -> {
                map.put("submissionStatus", sub.getStatus());
                map.put("submittedAt", sub.getSubmittedAt().toString());
                gradeRepository.findBySubmissionId(sub.getId()).ifPresent(g -> {
                    map.put("myScore", g.getScore());
                    map.put("score", g.getScore());
                    map.put("isReturned", g.isReturned());
                    map.put("feedback", g.getFeedback());
                    map.put("grade", formatGrade(g));
                });
            }, () -> {
                boolean overdue = a.getDueDate() != null && LocalDateTime.now().isAfter(a.getDueDate());
                map.put("submissionStatus", overdue ? "MISSING" : "ASSIGNED");
            });
        } else {
            long turnedIn = submissionRepository.countByAssignmentIdAndStatus(a.getId(), "TURNED_IN")
                    + submissionRepository.countByAssignmentIdAndStatus(a.getId(), "LATE");
            long graded = submissionRepository.countByAssignmentIdAndStatus(a.getId(), "GRADED")
                    + submissionRepository.countByAssignmentIdAndStatus(a.getId(), "RETURNED");
            long totalStudents = memberRepository.countActiveStudents(a.getClassroom().getId());
            map.put("turnedInCount", turnedIn);
            map.put("gradedCount", graded);
            map.put("assignedCount", totalStudents);
        }

        return map;
    }

    private Map<String, Object> formatSubmission(AssignmentSubmissionEntity s) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", s.getId());
        map.put("assignmentId", s.getAssignment().getId());
        map.put("studentId", s.getStudent().getId());
        map.put("studentName", s.getStudent().getName());
        map.put("studentEmail", s.getStudent().getEmail());
        map.put("submissionText", s.getSubmissionText());
        map.put("status", s.getStatus());
        map.put("versionNumber", s.getVersionNumber());
        map.put("submittedAt", s.getSubmittedAt().toString());

        List<AssignmentAttachmentEntity> attachments = attachmentRepository.findBySubmissionIdOrderByUploadedAtAsc(s.getId());
        map.put("attachments", attachments.stream().map(this::formatAttachment).collect(Collectors.toList()));
        return map;
    }

    private Map<String, Object> formatAttachment(AssignmentAttachmentEntity att) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", att.getId());
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
        map.put("id", g.getId());
        map.put("submissionId", g.getSubmission().getId());
        map.put("score", g.getScore());
        map.put("feedback", g.getFeedback());
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
            } catch (Exception invalid) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Due date must be a valid ISO date and time.");
            }
        }
    }
}
