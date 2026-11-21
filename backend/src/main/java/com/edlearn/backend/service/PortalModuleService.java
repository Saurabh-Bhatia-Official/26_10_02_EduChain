package com.edlearn.backend.service;

import com.edlearn.backend.dto.PortalRequests.AnnouncementRequest;
import com.edlearn.backend.dto.PortalRequests.DecisionRequest;
import com.edlearn.backend.dto.PortalRequests.LeaveRequest;
import com.edlearn.backend.model.*;
import com.edlearn.backend.repository.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class PortalModuleService {
    private final AnnouncementRepository announcementRepository;
    private final AnnouncementReadRepository announcementReadRepository;
    private final LeaveApplicationRepository leaveRepository;
    private final LeaveApprovalRepository approvalRepository;
    private final PortalNotificationRepository notificationRepository;
    private final UserRepository userRepository;

    @Value("${edlearn.leave.student-admin-second-stage:true}")
    private boolean studentAdminSecondStage;

    public PortalModuleService(AnnouncementRepository announcementRepository,
                               AnnouncementReadRepository announcementReadRepository,
                               LeaveApplicationRepository leaveRepository,
                               LeaveApprovalRepository approvalRepository,
                               PortalNotificationRepository notificationRepository,
                               UserRepository userRepository) {
        this.announcementRepository = announcementRepository;
        this.announcementReadRepository = announcementReadRepository;
        this.leaveRepository = leaveRepository;
        this.approvalRepository = approvalRepository;
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> announcements(UserEntity actor) {
        boolean admin = "admin".equalsIgnoreCase(actor.getRole());
        return announcementRepository
                .findByPublisher_InstituteCodeIgnoreCaseOrderByAnnouncementDateDescCreatedAtDesc(actor.getInstituteCode())
                .stream()
                .filter(a -> admin || (a.isPublished() && audienceIncludes(a.getAudience(), actor.getRole())
                        && (a.getExpiresAt() == null || !a.getExpiresAt().isBefore(LocalDate.now()))))
                .map(a -> announcementMap(a, actor))
                .toList();
    }

    @Transactional
    public Map<String, Object> createAnnouncement(UserEntity admin, AnnouncementRequest request) {
        validateAnnouncement(request);
        AnnouncementEntity entity = new AnnouncementEntity();
        entity.setPublisher(admin);
        updateAnnouncement(entity, request);
        entity = announcementRepository.save(entity);
        if (entity.isPublished()) notifyAnnouncementAudience(entity);
        return announcementMap(entity, admin);
    }

    @Transactional
    public Map<String, Object> updateAnnouncement(UserEntity admin, UUID id, AnnouncementRequest request) {
        validateAnnouncement(request);
        AnnouncementEntity entity = findAnnouncement(admin, id);
        boolean wasPublished = entity.isPublished();
        if (wasPublished) clearAnnouncementDelivery(entity);
        updateAnnouncement(entity, request);
        entity = announcementRepository.save(entity);
        if (request.published()) notifyAnnouncementAudience(entity);
        return announcementMap(entity, admin);
    }

    @Transactional
    public void deleteAnnouncement(UserEntity admin, UUID id) {
        AnnouncementEntity announcement = findAnnouncement(admin, id);
        clearAnnouncementDelivery(announcement);
        announcementRepository.delete(announcement);
    }

    @Transactional
    public void markAnnouncementRead(UserEntity actor, UUID id) {
        AnnouncementEntity announcement = announcementRepository.findById(id)
                .filter(a -> Objects.equals(a.getPublisher().getInstituteCode(), actor.getInstituteCode()))
                .filter(a -> a.isPublished() && audienceIncludes(a.getAudience(), actor.getRole()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Announcement not found."));
        if (!announcementReadRepository.existsByAnnouncementAndUser(announcement, actor)) {
            announcementReadRepository.save(new AnnouncementReadEntity(announcement, actor));
        }
        notificationRepository.findByUserAndTargetTypeAndTargetIdAndReadAtIsNull(actor, "ANNOUNCEMENT", id.toString())
                .forEach(n -> n.setReadAt(LocalDateTime.now()));
    }

    @Transactional
    public Map<String, Object> assignTeacher(UserEntity admin, UUID studentId, UUID teacherId) {
        UserEntity student = userRepository.findById(studentId)
                .filter(u -> "student".equalsIgnoreCase(u.getRole()))
                .filter(u -> Objects.equals(u.getInstituteCode(), admin.getInstituteCode()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found."));
        UserEntity teacher = userRepository.findById(teacherId)
                .filter(u -> "teacher".equalsIgnoreCase(u.getRole()))
                .filter(u -> Objects.equals(u.getInstituteCode(), admin.getInstituteCode()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Teacher not found."));
        student.setAssignedTeacher(teacher);
        userRepository.save(student);
        return Map.of("studentId", student.getId(), "teacherId", teacher.getId(), "teacherName", teacher.getName());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> assignmentOptions(UserEntity admin) {
        List<Map<String, Object>> students = userRepository
                .findByInstituteCodeIgnoreCaseAndRoleIgnoreCase(admin.getInstituteCode(), "student").stream()
                .map(student -> {
                    Map<String, Object> item = userSummary(student);
                    item.put("assignedTeacherId", student.getAssignedTeacher() == null ? null : student.getAssignedTeacher().getId());
                    item.put("assignedTeacherName", student.getAssignedTeacher() == null ? null : student.getAssignedTeacher().getName());
                    return item;
                }).toList();
        List<Map<String, Object>> teachers = userRepository
                .findByInstituteCodeIgnoreCaseAndRoleIgnoreCase(admin.getInstituteCode(), "teacher").stream()
                .map(this::userSummary).toList();
        return Map.of("students", students, "teachers", teachers);
    }

    @Transactional
    public Map<String, Object> submitLeave(UserEntity actor, LeaveRequest request) {
        validateLeave(request);
        if (leaveRepository.existsByApplicantAndStartDateAndEndDateAndLeaveTypeIgnoreCase(
                actor, request.startDate(), request.endDate(), request.leaveType().trim())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "An application with these dates and leave type already exists.");
        }
        LeaveApplicationEntity application = new LeaveApplicationEntity();
        application.setApplicant(actor);
        application.setLeaveType(request.leaveType().trim());
        application.setStartDate(request.startDate());
        application.setEndDate(request.endDate());
        application.setReason(request.reason().trim());
        application.setDocumentUrl(sanitizeDocumentUrl(request.documentUrl()));
        if ("student".equalsIgnoreCase(actor.getRole())) {
            UserEntity assignedTeacher = actor.getAssignedTeacher();
            if (assignedTeacher == null || !"teacher".equalsIgnoreCase(assignedTeacher.getRole())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Contact your Admin to assign a teacher before applying for leave.");
            }
            application.setAssignedTeacher(assignedTeacher);
        }
        application = leaveRepository.save(application);
        String targetType = "LEAVE";
        String message = actor.getName() + " submitted a leave application.";
        if ("student".equalsIgnoreCase(actor.getRole())) {
            createNotification(application.getAssignedTeacher(), "LEAVE_REQUEST", message, application.getId().toString(), targetType);
        } else {
            notifyAdmins(actor.getInstituteCode(), actor.getId(), "TEACHER_LEAVE_REQUEST", message,
                    application.getId().toString(), targetType);
        }
        return leaveMap(application, actor);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> leaves(UserEntity actor, String status, String applicantRole,
                                            LocalDate from, LocalDate to, String search) {
        List<LeaveApplicationEntity> applications;
        String role = actor.getRole().toLowerCase(Locale.ROOT);
        String actorInstCode = actor.getInstituteCode();
        if ("admin".equals(role)) {
            applications = leaveRepository.findAll().stream()
                    .filter(item -> item.getApplicant() != null &&
                            (actorInstCode == null || item.getApplicant().getInstituteCode() == null ||
                             item.getApplicant().getInstituteCode().equalsIgnoreCase(actorInstCode)))
                    .collect(java.util.stream.Collectors.toCollection(ArrayList::new));
        } else if ("teacher".equals(role)) {
            Map<UUID, LeaveApplicationEntity> visible = new LinkedHashMap<>();
            leaveRepository.findByAssignedTeacherOrderByCreatedAtDesc(actor).forEach(item -> visible.put(item.getId(), item));
            leaveRepository.findByApplicantOrderByCreatedAtDesc(actor).forEach(item -> visible.put(item.getId(), item));
            applications = new ArrayList<>(visible.values());
        } else {
            applications = leaveRepository.findByApplicantOrderByCreatedAtDesc(actor);
        }
        String normalizedStatus = status == null ? "" : status.trim().toUpperCase(Locale.ROOT);
        String normalizedRole = applicantRole == null ? "" : applicantRole.trim().toLowerCase(Locale.ROOT);
        String query = search == null ? "" : search.trim().toLowerCase(Locale.ROOT);
        return applications.stream()
                .filter(item -> item.getApplicant() != null)
                .filter(item -> normalizedStatus.isEmpty() || item.getStatus().equalsIgnoreCase(normalizedStatus))
                .filter(item -> normalizedRole.isEmpty() || (item.getApplicant().getRole() != null && item.getApplicant().getRole().equalsIgnoreCase(normalizedRole)))
                .filter(item -> from == null || !item.getEndDate().isBefore(from))
                .filter(item -> to == null || !item.getStartDate().isAfter(to))
                .filter(item -> query.isEmpty() || contains(item.getApplicant().getName(), query)
                        || contains(item.getApplicant().getEmail(), query)
                        || contains(item.getApplicant().getRollNumber(), query)
                        || contains(item.getApplicant().getInstructorId(), query))
                .sorted(Comparator.comparing(LeaveApplicationEntity::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder())))
                .map(item -> leaveMap(item, actor))
                .toList();
    }

    private boolean contains(String value, String query) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(query);
    }

    @Transactional
    public Map<String, Object> decideLeave(UserEntity actor, UUID id, DecisionRequest request) {
        String decision = request.decision().trim().toUpperCase(Locale.ROOT);
        if (!Set.of("APPROVED", "REJECTED").contains(decision)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Decision must be Approved or Rejected.");
        }
        LeaveApplicationEntity application = leaveRepository.findById(id)
                .filter(item -> Objects.equals(item.getApplicant().getInstituteCode(), actor.getInstituteCode()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Leave application not found."));
        UserEntity applicant = application.getApplicant();
        if (applicant.getId().equals(actor.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You cannot approve your own application.");
        }
        String actorRole = actor.getRole().toLowerCase(Locale.ROOT);
        boolean studentApplication = "student".equalsIgnoreCase(applicant.getRole());
        if ("teacher".equals(actorRole)) {
            if (!studentApplication || application.getAssignedTeacher() == null
                    || !application.getAssignedTeacher().getId().equals(actor.getId())
                    || !"PENDING".equals(application.getStatus())) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "This request is not assigned to you for review.");
            }
            application.setStatus(studentAdminSecondStage && "APPROVED".equals(decision) ? "WAITING_ADMIN" : decision);
        } else if ("admin".equals(actorRole)) {
            if (studentApplication) {
                if (!studentAdminSecondStage || !"WAITING_ADMIN".equals(application.getStatus())) {
                    throw new ResponseStatusException(HttpStatus.CONFLICT, "This student application is not awaiting Admin approval.");
                }
            } else if (!"teacher".equalsIgnoreCase(applicant.getRole()) || !"PENDING".equals(application.getStatus())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "This teacher application is not pending.");
            }
            application.setStatus(decision);
        } else {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Your account cannot review leave applications.");
        }
        approvalRepository.save(new LeaveApprovalEntity(application, actor, decision,
                request.remark() == null ? null : request.remark().trim()));
        application.setUpdatedAt(LocalDateTime.now());
        leaveRepository.save(application);
        if ("WAITING_ADMIN".equals(application.getStatus())) {
            notifyAdmins(actor.getInstituteCode(), actor.getId(), "LEAVE_ADMIN_REVIEW",
                    "A student leave application requires Admin approval.", id.toString(), "LEAVE");
            createNotification(applicant, "LEAVE_DECISION",
                    "Your teacher approved the application; it is awaiting Admin approval.",
                    id.toString(), "LEAVE");
        } else {
            createNotification(applicant, "LEAVE_DECISION",
                    "Your leave application was " + decision.toLowerCase(Locale.ROOT) + ".",
                    id.toString(), "LEAVE");
        }
        return leaveMap(application, actor);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> notifications(UserEntity actor) {
        return notificationRepository.findTop50ByUserOrderByCreatedAtDesc(actor).stream()
                .map(notification -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("id", notification.getId());
                    item.put("type", notification.getType());
                    item.put("message", notification.getMessage());
                    item.put("targetId", notification.getTargetId());
                    item.put("targetType", notification.getTargetType());
                    item.put("createdAt", notification.getCreatedAt());
                    item.put("read", notification.getReadAt() != null);
                    return item;
                }).toList();
    }

    @Transactional(readOnly = true)
    public long unreadNotificationCount(UserEntity actor) {
        return notificationRepository.countByUserAndReadAtIsNull(actor);
    }

    @Transactional
    public void markNotificationRead(UserEntity actor, UUID notificationId) {
        PortalNotificationEntity notification = notificationRepository.findById(notificationId)
                .filter(item -> item.getUser().getId().equals(actor.getId()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Notification not found."));
        if (notification.getReadAt() == null) notification.setReadAt(LocalDateTime.now());
    }

    private void updateAnnouncement(AnnouncementEntity entity, AnnouncementRequest request) {
        entity.setTitle(request.title().trim());
        entity.setDescription(request.description().trim());
        entity.setAudience(request.audience().trim().toUpperCase(Locale.ROOT));
        entity.setAnnouncementDate(request.announcementDate());
        entity.setExpiresAt(request.expiresAt());
        entity.setPublished(request.published());
    }

    private void validateAnnouncement(AnnouncementRequest request) {
        String audience = request.audience().trim().toUpperCase(Locale.ROOT);
        if (!Set.of("STUDENTS", "TEACHERS", "BOTH").contains(audience)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Audience must be Students, Teachers, or Both.");
        }
        if (request.expiresAt() != null && request.expiresAt().isBefore(request.announcementDate())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Expiry date cannot be before announcement date.");
        }
    }

    private void validateLeave(LeaveRequest request) {
        if (request.endDate().isBefore(request.startDate())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "End date cannot be before start date.");
        }
        if (request.startDate().isBefore(LocalDate.now())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Leave cannot start in the past.");
        }
        if (request.reason().trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "A reason is required.");
        }
    }

    private String sanitizeDocumentUrl(String value) {
        if (value == null || value.isBlank()) return null;
        String url = value.trim();
        if (!url.startsWith("https://") || url.length() > 1000) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Supporting document URL must be a valid HTTPS URL.");
        }
        return url;
    }

    private AnnouncementEntity findAnnouncement(UserEntity admin, UUID id) {
        return announcementRepository.findById(id)
                .filter(a -> Objects.equals(a.getPublisher().getInstituteCode(), admin.getInstituteCode()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Announcement not found."));
    }

    private boolean audienceIncludes(String audience, String role) {
        return "BOTH".equalsIgnoreCase(audience)
                || ("STUDENTS".equalsIgnoreCase(audience) && "student".equalsIgnoreCase(role))
                || ("TEACHERS".equalsIgnoreCase(audience) && "teacher".equalsIgnoreCase(role));
    }

    private Map<String, Object> announcementMap(AnnouncementEntity a, UserEntity actor) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("id", a.getId());
        item.put("title", a.getTitle());
        item.put("description", a.getDescription());
        item.put("audience", a.getAudience());
        item.put("announcementDate", a.getAnnouncementDate());
        item.put("expiresAt", a.getExpiresAt());
        item.put("published", a.isPublished());
        item.put("publisher", a.getPublisher().getName());
        item.put("createdAt", a.getCreatedAt());
        item.put("read", announcementReadRepository.existsByAnnouncementAndUser(a, actor));
        return item;
    }

    private void notifyAnnouncementAudience(AnnouncementEntity announcement) {
        List<String> roles = "BOTH".equals(announcement.getAudience())
                ? List.of("student", "teacher")
                : List.of("STUDENTS".equals(announcement.getAudience()) ? "student" : "teacher");
        for (String role : roles) {
            userRepository.findByInstituteCodeIgnoreCaseAndRoleIgnoreCase(
                    announcement.getPublisher().getInstituteCode(), role).stream()
                    .filter(user -> !user.getId().equals(announcement.getPublisher().getId()))
                    .forEach(user -> createNotification(user, "ANNOUNCEMENT",
                            "New announcement: " + announcement.getTitle(),
                            announcement.getId().toString(), "ANNOUNCEMENT"));
        }
    }

    private void clearAnnouncementDelivery(AnnouncementEntity announcement) {
        announcementReadRepository.deleteByAnnouncement(announcement);
        notificationRepository.deleteByTargetTypeAndTargetId("ANNOUNCEMENT", announcement.getId().toString());
    }

    private Map<String, Object> leaveMap(LeaveApplicationEntity application, UserEntity viewer) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("id", application.getId());
        item.put("applicant", userSummary(application.getApplicant()));
        item.put("leaveType", application.getLeaveType());
        item.put("startDate", application.getStartDate());
        item.put("endDate", application.getEndDate());
        item.put("reason", application.getReason());
        item.put("documentUrl", application.getDocumentUrl());
        item.put("status", application.getStatus());
        item.put("createdAt", application.getCreatedAt());
        item.put("updatedAt", application.getUpdatedAt());
        item.put("assignedTeacherName", application.getAssignedTeacher() == null ? null : application.getAssignedTeacher().getName());
        List<Map<String, Object>> approvals = approvalRepository.findByApplicationOrderByReviewedAtAsc(application).stream()
                .map(approval -> {
                    Map<String, Object> history = new LinkedHashMap<>();
                    history.put("decision", approval.getDecision());
                    history.put("reviewer", approval.getReviewer() != null ? approval.getReviewer().getName() : "System");
                    history.put("remark", approval.getRemark());
                    history.put("reviewedAt", approval.getReviewedAt());
                    return history;
                }).toList();
        item.put("approvalHistory", approvals);
        item.put("viewerRemark", approvals.stream()
                .filter(approval -> Objects.equals(viewer.getName(), approval.get("reviewer")))
                .map(approval -> approval.get("remark"))
                .filter(Objects::nonNull).reduce((first, second) -> second).orElse(null));
        return item;
    }

    private Map<String, Object> userSummary(UserEntity user) {
        if (user == null) return Collections.emptyMap();
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("id", user.getId());
        item.put("name", user.getName());
        item.put("email", user.getEmail());
        item.put("role", user.getRole());
        item.put("rollNumber", user.getRollNumber());
        item.put("className", user.getClassName());
        item.put("instructorId", user.getInstructorId());
        return item;
    }

    private void createNotification(UserEntity recipient, String type, String message, String targetId, String targetType) {
        if (recipient == null) return;
        PortalNotificationEntity notification = new PortalNotificationEntity();
        notification.setUser(recipient);
        notification.setType(type);
        notification.setMessage(message);
        notification.setTargetId(targetId);
        notification.setTargetType(targetType);
        notificationRepository.save(notification);
    }

    private void notifyAdmins(String instituteCode, UUID excludedUserId, String type, String message,
                              String targetId, String targetType) {
        String code = instituteCode != null && !instituteCode.isBlank() ? instituteCode : "INST-2025";
        userRepository.findByInstituteCodeIgnoreCaseAndRoleIgnoreCase(code, "admin").stream()
                .filter(admin -> !admin.getId().equals(excludedUserId))
                .forEach(admin -> createNotification(admin, type, message, targetId, targetType));
    }
}
