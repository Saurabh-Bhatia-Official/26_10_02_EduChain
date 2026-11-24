package com.edlearn.backend.service;

import com.edlearn.backend.model.ClassroomEntity;
import com.edlearn.backend.model.ClassroomMemberEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.ClassroomMemberRepository;
import com.edlearn.backend.repository.ClassroomRepository;
import com.edlearn.backend.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ClassroomService {

    private static final String CODE_ALPHABET = "23456789abcdefghjkmnpqrstuvwxyz";
    private static final SecureRandom RANDOM = new SecureRandom();

    private final ClassroomRepository classroomRepository;
    private final ClassroomMemberRepository memberRepository;
    private final UserRepository userRepository;

    public ClassroomService(ClassroomRepository classroomRepository,
                            ClassroomMemberRepository memberRepository,
                            UserRepository userRepository) {
        this.classroomRepository = classroomRepository;
        this.memberRepository = memberRepository;
        this.userRepository = userRepository;
    }

    private String generateInvitationCode() {
        while (true) {
            StringBuilder sb = new StringBuilder(8);
            for (int i = 0; i < 8; i++) {
                sb.append(CODE_ALPHABET.charAt(RANDOM.nextInt(CODE_ALPHABET.length())));
            }
            String code = sb.toString();
            if (classroomRepository.findByInvitationCodeIgnoreCase(code).isEmpty()) {
                return code;
            }
        }
    }

    @Transactional
    public Map<String, Object> createClassroom(UserEntity creator, Map<String, Object> body) {
        String name = (String) body.get("name");
        if (name == null || name.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Classroom name is required.");
        }

        ClassroomEntity classroom = new ClassroomEntity();
        classroom.setName(name.trim());
        classroom.setSection((String) body.get("section"));
        classroom.setSubject((String) body.get("subject"));
        classroom.setRoom((String) body.get("room"));
        classroom.setDescription((String) body.get("description"));
        classroom.setBannerUrl((String) body.get("bannerUrl"));
        
        String themeColor = (String) body.get("themeColor");
        if (themeColor != null && !themeColor.isBlank()) {
            classroom.setThemeColor(themeColor.trim());
        }

        classroom.setPublic(Boolean.TRUE.equals(body.get("isPublic")));
        classroom.setRequiresApproval(Boolean.TRUE.equals(body.get("requiresApproval")));
        classroom.setInvitationCode(generateInvitationCode());
        classroom.setCreator(creator);
        classroom.setInstituteCode(creator.getInstituteCode());
        classroom.setCreatedAt(LocalDateTime.now());
        classroom.setUpdatedAt(LocalDateTime.now());

        ClassroomEntity saved = classroomRepository.save(classroom);

        // Add creator as primary TEACHER
        ClassroomMemberEntity member = new ClassroomMemberEntity(saved, creator, "TEACHER", "ACTIVE");
        memberRepository.save(member);

        return formatClassroom(saved, "TEACHER");
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getUserClassrooms(UserEntity user) {
        List<ClassroomMemberEntity> memberships = memberRepository.findByUserIdAndStatus(user.getId(), "ACTIVE");
        return memberships.stream()
                .map(m -> formatClassroom(m.getClassroom(), m.getRole()))
                .filter(m -> !Boolean.TRUE.equals(m.get("isArchived")))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getClassroomDetails(UserEntity user, UUID classroomId) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));

        Optional<ClassroomMemberEntity> memberOpt = memberRepository.findByClassroomIdAndUserId(classroomId, user.getId());
        boolean isAdmin = isInstituteAdmin(user, classroom);

        boolean activeMember = memberOpt.map(m -> "ACTIVE".equalsIgnoreCase(m.getStatus())).orElse(false);
        if (!activeMember && !isAdmin && !classroom.isPublic()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have access to this classroom.");
        }

        String userRole = activeMember ? memberOpt.map(ClassroomMemberEntity::getRole).orElse("GUEST") : isAdmin ? "ADMIN" : "GUEST";
        String memberStatus = memberOpt.map(ClassroomMemberEntity::getStatus).orElse("NONE");

        Map<String, Object> map = formatClassroom(classroom, userRole);
        map.put("membershipStatus", memberStatus);
        return map;
    }

    @Transactional(readOnly = true)
    public void requireClassroomAccess(UserEntity user, UUID classroomId) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));
        requireSameInstitute(user, classroom);
        if (isInstituteAdmin(user, classroom) || classroom.isPublic()
                || memberRepository.existsByClassroomIdAndUserIdAndStatus(classroomId, user.getId(), "ACTIVE")) return;
        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have access to this classroom.");
    }

    @Transactional
    public Map<String, Object> updateClassroom(UserEntity user, UUID classroomId, Map<String, Object> body) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));

        checkTeacherOrAdmin(user, classroom);

        if (body.containsKey("name")) classroom.setName(((String) body.get("name")).trim());
        if (body.containsKey("section")) classroom.setSection((String) body.get("section"));
        if (body.containsKey("subject")) classroom.setSubject((String) body.get("subject"));
        if (body.containsKey("room")) classroom.setRoom((String) body.get("room"));
        if (body.containsKey("description")) classroom.setDescription((String) body.get("description"));
        if (body.containsKey("bannerUrl")) classroom.setBannerUrl((String) body.get("bannerUrl"));
        if (body.containsKey("themeColor")) classroom.setThemeColor((String) body.get("themeColor"));
        if (body.containsKey("isPublic")) classroom.setPublic(Boolean.TRUE.equals(body.get("isPublic")));
        if (body.containsKey("requiresApproval")) classroom.setRequiresApproval(Boolean.TRUE.equals(body.get("requiresApproval")));
        classroom.setUpdatedAt(LocalDateTime.now());

        ClassroomEntity saved = classroomRepository.save(classroom);
        return formatClassroom(saved, "TEACHER");
    }

    @Transactional
    public Map<String, Object> joinByInvitationCode(UserEntity user, String code) {
        if (code == null || code.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invitation code is required.");
        }
        ClassroomEntity classroom = classroomRepository.findByInvitationCodeIgnoreCase(code.trim())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Invalid invitation code. No matching classroom found."));

        if (classroom.isArchived()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "This classroom is archived and not accepting new enrollments.");
        }

        Optional<ClassroomMemberEntity> existingOpt = memberRepository.findByClassroomIdAndUserId(classroom.getId(), user.getId());
        if (existingOpt.isPresent()) {
            ClassroomMemberEntity existing = existingOpt.get();
            if ("ACTIVE".equalsIgnoreCase(existing.getStatus())) {
                return Map.of("message", "Already enrolled in this classroom.", "status", "ACTIVE", "classroom", formatClassroom(classroom, existing.getRole()));
            } else if ("PENDING_APPROVAL".equalsIgnoreCase(existing.getStatus())) {
                return Map.of("message", "Your enrollment request is awaiting teacher approval.", "status", "PENDING_APPROVAL", "classroom", formatClassroom(classroom, existing.getRole()));
            }
        }

        String role = ("teacher".equalsIgnoreCase(user.getRole()) || "instructor".equalsIgnoreCase(user.getRole())) ? "CO_TEACHER" : "STUDENT";
        String status = classroom.isRequiresApproval() && !"CO_TEACHER".equals(role) ? "PENDING_APPROVAL" : "ACTIVE";

        ClassroomMemberEntity member = existingOpt.orElse(new ClassroomMemberEntity());
        member.setClassroom(classroom);
        member.setUser(user);
        member.setRole(role);
        member.setStatus(status);
        member.setEnrolledAt(LocalDateTime.now());
        memberRepository.save(member);

        String message = "ACTIVE".equals(status) ? "Successfully enrolled in classroom!" : "Enrollment request submitted. Awaiting teacher approval.";
        return Map.of("message", message, "status", status, "classroom", formatClassroom(classroom, role));
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getMembers(UserEntity user, UUID classroomId) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));

        requireSameInstitute(user, classroom);
        boolean activeMember = memberRepository.existsByClassroomIdAndUserIdAndStatus(classroomId, user.getId(), "ACTIVE");
        if (!activeMember && !canManageClassroom(user, classroom)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only classroom members can view the roster.");
        }

        List<ClassroomMemberEntity> allMembers = memberRepository.findByClassroomIdOrderByRoleAscEnrolledAtAsc(classroomId);

        List<Map<String, Object>> teachers = new ArrayList<>();
        List<Map<String, Object>> students = new ArrayList<>();
        List<Map<String, Object>> pending = new ArrayList<>();

        for (ClassroomMemberEntity m : allMembers) {
            Map<String, Object> memberMap = formatMember(m);
            if ("PENDING_APPROVAL".equalsIgnoreCase(m.getStatus())) {
                pending.add(memberMap);
            } else if ("ACTIVE".equalsIgnoreCase(m.getStatus())) {
                if ("TEACHER".equalsIgnoreCase(m.getRole()) || "CO_TEACHER".equalsIgnoreCase(m.getRole())) {
                    teachers.add(memberMap);
                } else {
                    students.add(memberMap);
                }
            }
        }

        Map<String, Object> response = new HashMap<>();
        response.put("teachers", teachers);
        response.put("students", students);
        
        // Only return pending queue to teachers or admins
        boolean canManage = canManageClassroom(user, classroom);
        if (canManage) {
            response.put("pendingApprovals", pending);
        }

        return response;
    }

    @Transactional
    public Map<String, Object> updateMemberStatus(UserEntity user, UUID classroomId, UUID targetUserId, String newStatus) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));

        requireSameInstitute(user, classroom);
        if (!canManageClassroom(user, classroom)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only teachers or administrators can approve or remove members.");
        }

        ClassroomMemberEntity member = memberRepository.findByClassroomIdAndUserId(classroomId, targetUserId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Member record not found."));

        if (!"STUDENT".equalsIgnoreCase(member.getRole())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Only student membership can be changed here.");
        }

        if ("REJECTED".equalsIgnoreCase(newStatus) || "REMOVED".equalsIgnoreCase(newStatus)) {
            memberRepository.delete(member);
            return Map.of("message", "Member removed successfully.", "status", "REMOVED");
        } else if ("ACTIVE".equalsIgnoreCase(newStatus)
                && "PENDING_APPROVAL".equalsIgnoreCase(member.getStatus())) {
            member.setStatus("ACTIVE");
            memberRepository.save(member);
            return Map.of("message", "Member status updated to " + member.getStatus(), "status", member.getStatus());
        }
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Membership can only be approved or removed.");
    }

    @Transactional
    public Map<String, Object> archiveClassroom(UserEntity user, UUID classroomId, boolean archive) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));

        checkTeacherOrAdmin(user, classroom);
        classroom.setArchived(archive);
        classroom.setUpdatedAt(LocalDateTime.now());
        classroomRepository.save(classroom);

        return Map.of("id", classroomId, "isArchived", archive, "message", archive ? "Classroom archived." : "Classroom restored.");
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> searchPublicClassrooms(String query) {
        List<ClassroomEntity> list;
        if (query != null && !query.trim().isEmpty()) {
            list = classroomRepository.searchPublicClassrooms(query.trim());
        } else {
            list = classroomRepository.findPublicClassrooms();
        }
        return list.stream().map(c -> formatClassroom(c, "GUEST")).collect(Collectors.toList());
    }

    private boolean canManageClassroom(UserEntity user, ClassroomEntity classroom) {
        if ("admin".equalsIgnoreCase(user.getRole())) return isInstituteAdmin(user, classroom);
        if (classroom.getCreator().getId().equals(user.getId())) return true;
        return memberRepository.findByClassroomIdAndUserId(classroom.getId(), user.getId())
                .map(m -> "ACTIVE".equalsIgnoreCase(m.getStatus())
                        && ("TEACHER".equalsIgnoreCase(m.getRole()) || "CO_TEACHER".equalsIgnoreCase(m.getRole())))
                .orElse(false);
    }

    private boolean isInstituteAdmin(UserEntity user, ClassroomEntity classroom) {
        return "admin".equalsIgnoreCase(user.getRole()) && user.getInstituteCode() != null
                && classroom.getInstituteCode() != null
                && user.getInstituteCode().equalsIgnoreCase(classroom.getInstituteCode());
    }

    private void requireSameInstitute(UserEntity user, ClassroomEntity classroom) {
        if (user.getInstituteCode() == null || classroom.getInstituteCode() == null
                || !user.getInstituteCode().equalsIgnoreCase(classroom.getInstituteCode())) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found.");
        }
    }

    private void checkTeacherOrAdmin(UserEntity user, ClassroomEntity classroom) {
        requireSameInstitute(user, classroom);
        if (!canManageClassroom(user, classroom)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only classroom teachers or administrators can perform this action.");
        }
    }

    private Map<String, Object> formatClassroom(ClassroomEntity c, String userRole) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", c.getId());
        map.put("name", c.getName());
        map.put("section", c.getSection() != null ? c.getSection() : "");
        map.put("subject", c.getSubject() != null ? c.getSubject() : "");
        map.put("room", c.getRoom() != null ? c.getRoom() : "");
        map.put("description", c.getDescription() != null ? c.getDescription() : "");
        map.put("invitationCode", c.getInvitationCode());
        map.put("bannerUrl", c.getBannerUrl());
        map.put("themeColor", c.getThemeColor());
        map.put("isPublic", c.isPublic());
        map.put("requiresApproval", c.isRequiresApproval());
        map.put("isArchived", c.isArchived());
        map.put("creatorName", c.getCreator() != null ? c.getCreator().getName() : "Instructor");
        map.put("creatorEmail", c.getCreator() != null ? c.getCreator().getEmail() : "");
        map.put("studentCount", memberRepository.countActiveStudents(c.getId()));
        map.put("myRole", userRole);
        map.put("createdAt", c.getCreatedAt().toString());
        return map;
    }

    private Map<String, Object> formatMember(ClassroomMemberEntity m) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", m.getId());
        map.put("userId", m.getUser().getId());
        map.put("name", m.getUser().getName());
        map.put("email", m.getUser().getEmail());
        map.put("avatarUrl", m.getUser().getAvatarUrl());
        map.put("role", m.getRole());
        map.put("status", m.getStatus());
        map.put("enrolledAt", m.getEnrolledAt().toString());
        return map;
    }
}
