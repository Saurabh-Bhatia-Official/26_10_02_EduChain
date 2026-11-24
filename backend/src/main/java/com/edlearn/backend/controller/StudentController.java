package com.edlearn.backend.controller;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.model.ClassroomEntity;
import com.edlearn.backend.model.ClassroomMemberEntity;
import com.edlearn.backend.repository.ClassroomMemberRepository;
import com.edlearn.backend.repository.UserRepository;
import com.edlearn.backend.service.PortalAccessService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.LinkedHashMap;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@RestController
@RequestMapping("/api/students")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class StudentController {
    private static final BCryptPasswordEncoder PASSWORD_ENCODER = new BCryptPasswordEncoder();

    private final UserRepository userRepository;
    private final PortalAccessService accessService;
    private final ClassroomMemberRepository classroomMemberRepository;

    public StudentController(UserRepository userRepository, PortalAccessService accessService,
                             ClassroomMemberRepository classroomMemberRepository) {
        this.userRepository = userRepository;
        this.accessService = accessService;
        this.classroomMemberRepository = classroomMemberRepository;
    }

    private UserEntity findStudent(String id) {
        try {
            UUID uuid = UUID.fromString(id);
            Optional<UserEntity> byId = userRepository.findById(uuid);
            if (byId.isPresent() && "student".equalsIgnoreCase(byId.get().getRole())) {
                return byId.get();
            }
        } catch (Exception ignored) {}

        return userRepository.findByRollNumberIgnoreCase(id)
                .or(() -> userRepository.findByUserId(id))
                .or(() -> userRepository.findByEmailIgnoreCase(id))
                .filter(u -> "student".equalsIgnoreCase(u.getRole()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found: " + id));
    }

    @GetMapping
    public List<UserEntity> getAllStudents(HttpServletRequest request, @RequestParam(required = false) String search) {
        UserEntity actor = accessService.require(request, "admin", "teacher", "instructor");
        List<UserEntity> list;
        if ("admin".equalsIgnoreCase(actor.getRole())) {
            list = actor.getInstituteCode() != null
                    ? userRepository.findByInstituteCodeIgnoreCaseAndRoleIgnoreCaseOrderByCreatedAtDesc(actor.getInstituteCode(), "student")
                    : Collections.emptyList();
            if (list.isEmpty()) {
                list = userRepository.findAll().stream().filter(u -> "student".equalsIgnoreCase(u.getRole())).toList();
            }
        } else {
            list = studentsInTeacherClassrooms(actor);
            if (list.isEmpty()) {
                list = userRepository.findAll().stream().filter(u -> "student".equalsIgnoreCase(u.getRole())).toList();
            }
        }
        if (search != null && !search.isBlank()) {
            String q = search.toLowerCase();
            return list.stream()
                    .filter(s -> (s.getName() != null && s.getName().toLowerCase().contains(q)) ||
                                 (s.getEmail() != null && s.getEmail().toLowerCase().contains(q)) ||
                                 (s.getRollNumber() != null && s.getRollNumber().toLowerCase().contains(q)) ||
                                 (s.getClassName() != null && s.getClassName().toLowerCase().contains(q)) ||
                                 (s.getCourse() != null && s.getCourse().toLowerCase().contains(q)) ||
                                 (s.getDepartment() != null && s.getDepartment().toLowerCase().contains(q)))
                    .toList();
        }
        return list;
    }

    @GetMapping("/{id}")
    public UserEntity getStudent(HttpServletRequest request, @PathVariable String id) {
        UserEntity actor = accessService.require(request, "admin", "teacher");
        UserEntity student = findStudent(id);
        if ("admin".equalsIgnoreCase(actor.getRole()) && !sameInstitute(actor, student)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found.");
        }
        if ("teacher".equalsIgnoreCase(actor.getRole()) && studentsInTeacherClassrooms(actor).stream()
                .noneMatch(visible -> visible.getId().equals(student.getId()))) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found.");
        }
        return student;
    }

    public UserEntity getStudent(String id) {
        return findStudent(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserEntity createStudent(HttpServletRequest request, @RequestBody UserEntity student) {
        UserEntity actor = accessService.require(request, "admin");
        if (actor.getInstituteCode() == null || actor.getInstituteCode().isBlank()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Your admin account is not linked to an institute.");
        }
        student.setInstituteCode(actor.getInstituteCode());
        student.setInstituteName(actor.getInstituteName());
        return persistStudent(student);
    }

    private UserEntity persistStudent(UserEntity student) {
        if (student.getEmail() == null || student.getEmail().isBlank() || !student.getEmail().contains("@")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "A valid student email is required.");
        }
        if (student.getName() == null || student.getName().isBlank() || student.getRollNumber() == null || student.getRollNumber().isBlank()
                || student.getClassName() == null || student.getClassName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Student name, roll number, and class are required.");
        }
        String email = student.getEmail().trim();
        if (userRepository.existsByEmailIgnoreCase(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already exists: " + email);
        }
        if (student.getRollNumber() != null && !student.getRollNumber().isBlank()) {
            if (userRepository.existsByRollNumberIgnoreCase(student.getRollNumber().trim())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Roll number already exists: " + student.getRollNumber());
            }
        }

        student.setId(null);
        student.setRole("student");
        if (student.getUserId() == null || student.getUserId().isBlank()) {
            student.setUserId("std_" + System.currentTimeMillis());
        }

        // Validate and safeguard Name
        String name = student.getName();
        if (name == null || name.isBlank()) {
            name = student.getFullName();
        }
        if (name == null || name.isBlank()) {
            name = "Student";
        }
        student.setName(name.trim());

        String initialPassword = student.getPassword();
        if (initialPassword == null || initialPassword.length() < 8
                || Set.of("password123", "edlearn123").contains(initialPassword)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Set a non-default initial password of at least 8 characters.");
        }
        student.setEmail(email);
        student.setPassword(PASSWORD_ENCODER.encode(initialPassword));

        if (student.getStatus() == null || student.getStatus().isBlank()) {
            student.setStatus("Active");
        }
        if (student.getCourse() == null || student.getCourse().isBlank()) {
            student.setCourse(student.getClassName() != null && !student.getClassName().isBlank() ? student.getClassName() : "Computer Science & Engineering");
        }
        if (student.getClassName() == null || student.getClassName().isBlank()) {
            student.setClassName(student.getCourse());
        }
        if (student.getDepartment() == null || student.getDepartment().isBlank()) {
            student.setDepartment(student.getCourse());
        }
        if (student.getSemester() == null || student.getSemester().isBlank()) {
            student.setSemester("Semester 1");
        }
        if (student.getGender() == null || student.getGender().isBlank()) {
            student.setGender("Other");
        }
        if (student.getDob() == null || student.getDob().isBlank()) {
            student.setDob("2000-01-01");
        }
        if (student.getAddress() == null || student.getAddress().isBlank()) {
            student.setAddress("Campus Hostel");
        }
        if (student.getFatherName() == null || student.getFatherName().isBlank()) {
            student.setFatherName("Guardian of " + student.getName());
        }
        if (student.getFatherPhone() == null || student.getFatherPhone().isBlank()) {
            student.setFatherPhone(student.getPhone() != null && !student.getPhone().isBlank() ? student.getPhone() : "+91 99999 99999");
        }
        if (student.getFatherEmail() == null || student.getFatherEmail().isBlank()) {
            student.setFatherEmail(student.getEmail().replace("@", ".parent@"));
        }
        if (student.getMotherName() == null || student.getMotherName().isBlank()) {
            student.setMotherName("Guardian");
        }
        if (student.getMotherPhone() == null || student.getMotherPhone().isBlank()) {
            student.setMotherPhone(student.getPhone() != null && !student.getPhone().isBlank() ? student.getPhone() : "+91 99999 99999");
        }
        if (student.getMotherEmail() == null || student.getMotherEmail().isBlank()) {
            student.setMotherEmail(student.getEmail().replace("@", ".mother@"));
        }
        if (student.getInstituteCode() == null || student.getInstituteCode().isBlank()) {
            student.setInstituteCode("DEFAULT");
        }
        if (student.getInstituteName() == null || student.getInstituteName().isBlank()) {
            student.setInstituteName("Default Institute");
        }

        try {
            return userRepository.save(student);
        } catch (DataIntegrityViolationException ex) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "An account with this email already exists.", ex);
        }
    }

    @PutMapping("/{id}")
    public UserEntity updateStudent(HttpServletRequest request, @PathVariable String id, @RequestBody UserEntity updated) {
        UserEntity actor = accessService.require(request, "admin");
        UserEntity student = findStudent(id);
        requireSameInstitute(actor, student);

        if (updated.getName() != null && !updated.getName().isBlank()) {
            student.setName(updated.getName().trim());
        } else if (updated.getFullName() != null && !updated.getFullName().isBlank()) {
            student.setName(updated.getFullName().trim());
        }
        if (updated.getEmail() != null && !updated.getEmail().isBlank()) student.setEmail(updated.getEmail().trim());
        if (updated.getRollNumber() != null && !updated.getRollNumber().isBlank()) student.setRollNumber(updated.getRollNumber().trim());
        if (updated.getClassName() != null && !updated.getClassName().isBlank()) student.setClassName(updated.getClassName().trim());
        if (updated.getCourse() != null && !updated.getCourse().isBlank()) student.setCourse(updated.getCourse().trim());
        if (updated.getSemester() != null && !updated.getSemester().isBlank()) student.setSemester(updated.getSemester().trim());
        if (updated.getPhone() != null && !updated.getPhone().isBlank()) student.setPhone(updated.getPhone().trim());
        if (updated.getAddress() != null && !updated.getAddress().isBlank()) student.setAddress(updated.getAddress().trim());
        if (updated.getFatherName() != null && !updated.getFatherName().isBlank()) student.setFatherName(updated.getFatherName().trim());
        if (updated.getFatherPhone() != null && !updated.getFatherPhone().isBlank()) student.setFatherPhone(updated.getFatherPhone().trim());
        if (updated.getFatherEmail() != null && !updated.getFatherEmail().isBlank()) student.setFatherEmail(updated.getFatherEmail().trim());
        if (updated.getMotherName() != null && !updated.getMotherName().isBlank()) student.setMotherName(updated.getMotherName().trim());
        if (updated.getMotherPhone() != null && !updated.getMotherPhone().isBlank()) student.setMotherPhone(updated.getMotherPhone().trim());
        if (updated.getMotherEmail() != null && !updated.getMotherEmail().isBlank()) student.setMotherEmail(updated.getMotherEmail().trim());
        if (updated.getGender() != null && !updated.getGender().isBlank()) student.setGender(updated.getGender().trim());
        if (updated.getDob() != null && !updated.getDob().isBlank()) student.setDob(updated.getDob().trim());
        if (updated.getStatus() != null && !updated.getStatus().isBlank()) student.setStatus(updated.getStatus().trim());
        if (updated.getPassword() != null && !updated.getPassword().isBlank()) {
            if (updated.getPassword().length() < 8) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password must contain at least 8 characters.");
            student.setPassword(PASSWORD_ENCODER.encode(updated.getPassword()));
        }

        return userRepository.save(student);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteStudent(HttpServletRequest request, @PathVariable String id) {
        UserEntity actor = accessService.require(request, "admin");
        UserEntity student = findStudent(id);
        requireSameInstitute(actor, student);
        userRepository.delete(student);
        return ResponseEntity.ok(Map.of("success", true, "message", "Student deleted successfully", "id", id));
    }

    private List<UserEntity> studentsInTeacherClassrooms(UserEntity teacher) {
        Map<UUID, UserEntity> students = new LinkedHashMap<>();
        for (ClassroomMemberEntity teachingMembership : classroomMemberRepository.findByUserIdAndStatus(teacher.getId(), "ACTIVE")) {
            ClassroomEntity classroom = teachingMembership.getClassroom();
            boolean isOwner = classroom.getCreator() != null && classroom.getCreator().getId().equals(teacher.getId());
            boolean isTeacherMember = "TEACHER".equalsIgnoreCase(teachingMembership.getRole())
                    || "CO_TEACHER".equalsIgnoreCase(teachingMembership.getRole());
            if (classroom.isArchived() || (!isOwner && !isTeacherMember)) continue;
            for (ClassroomMemberEntity membership : classroomMemberRepository.findByClassroomIdAndStatus(classroom.getId(), "ACTIVE")) {
                UserEntity student = membership.getUser();
                if ("STUDENT".equalsIgnoreCase(membership.getRole()) && student != null
                        && "student".equalsIgnoreCase(student.getRole())
                        && Objects.equals(student.getInstituteCode(), teacher.getInstituteCode())) {
                    students.put(student.getId(), student);
                }
            }
        }
        return List.copyOf(students.values());
    }

    private boolean sameInstitute(UserEntity first, UserEntity second) {
        return first.getInstituteCode() != null && second.getInstituteCode() != null
                && first.getInstituteCode().equalsIgnoreCase(second.getInstituteCode());
    }

    private void requireSameInstitute(UserEntity actor, UserEntity target) {
        if (!sameInstitute(actor, target)) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found.");
    }
}
