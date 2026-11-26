package com.edlearn.backend.controller;

import com.edlearn.backend.model.InstructorProfileEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.InstructorProfileRepository;
import com.edlearn.backend.repository.UserRepository;
import com.edlearn.backend.service.PortalAccessService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@RestController
@RequestMapping({"/api/instructors", "/api/instructors/", "/instructors", "/instructors/"})
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class InstructorController {
    private static final BCryptPasswordEncoder PASSWORD_ENCODER = new BCryptPasswordEncoder();

    private final UserRepository userRepository;
    private final InstructorProfileRepository instructorProfileRepository;
    private final PortalAccessService accessService;

    public InstructorController(UserRepository userRepository,
                                InstructorProfileRepository instructorProfileRepository,
                                PortalAccessService accessService) {
        this.userRepository = userRepository;
        this.instructorProfileRepository = instructorProfileRepository;
        this.accessService = accessService;
    }

    private UserEntity findInstructor(String id) {
        try {
            UUID uuid = UUID.fromString(id);
            Optional<UserEntity> byId = userRepository.findById(uuid);
            if (byId.isPresent() && isInstructorRole(byId.get().getRole())) {
                return byId.get();
            }
        } catch (Exception ignored) {}

        return userRepository.findByInstructorIdIgnoreCase(id)
                .or(() -> userRepository.findByUserId(id))
                .or(() -> userRepository.findByEmailIgnoreCase(id))
                .filter(u -> isInstructorRole(u.getRole()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Instructor not found: " + id));
    }

    private boolean isInstructorRole(String role) {
        return "teacher".equalsIgnoreCase(role) || "instructor".equalsIgnoreCase(role);
    }

    @GetMapping
    public List<UserEntity> getAllInstructors(HttpServletRequest request, @RequestParam(required = false) String search) {
        UserEntity actor = accessService.resolveOptional(request).orElse(null);
        List<UserEntity> list;
        if (actor != null && actor.getInstituteCode() != null && !actor.getInstituteCode().isBlank()) {
            list = userRepository.findByInstituteCodeIgnoreCaseAndRoleIgnoreCaseOrderByCreatedAtDesc(actor.getInstituteCode(), "teacher");
            if (list.isEmpty()) {
                list = userRepository.findAll().stream().filter(u -> isInstructorRole(u.getRole())).toList();
            }
        } else {
            list = userRepository.findAll().stream().filter(u -> isInstructorRole(u.getRole())).toList();
        }

        if (search != null && !search.isBlank()) {
            String q = search.toLowerCase();
            return list.stream()
                    .filter(i -> (i.getName() != null && i.getName().toLowerCase().contains(q)) ||
                                 (i.getEmail() != null && i.getEmail().toLowerCase().contains(q)) ||
                                 (i.getInstructorId() != null && i.getInstructorId().toLowerCase().contains(q)) ||
                                 (i.getDepartment() != null && i.getDepartment().toLowerCase().contains(q)) ||
                                 (i.getDesignation() != null && i.getDesignation().toLowerCase().contains(q)))
                    .toList();
        }
        return list;
    }

    @GetMapping("/{id}")
    public UserEntity getInstructor(HttpServletRequest request, @PathVariable String id) {
        accessService.require(request, "admin", "teacher", "instructor");
        return findInstructor(id);
    }

    @GetMapping("/{id}/profile")
    public Map<String, Object> getInstructorProfile(HttpServletRequest request, @PathVariable String id) {
        accessService.require(request, "admin", "teacher", "instructor");
        UserEntity instructor = findInstructor(id);
        Optional<InstructorProfileEntity> profileOpt = instructorProfileRepository.findByUserId(instructor.getId());

        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", instructor.getId().toString());
        map.put("name", instructor.getName());
        map.put("email", instructor.getEmail());
        map.put("phone", instructor.getPhone());
        map.put("profileImage", instructor.getProfileImage());
        map.put("subject", instructor.getDepartment());
        map.put("expertise", profileOpt.map(InstructorProfileEntity::getExpertise).orElse(instructor.getDepartment()));
        map.put("qualification", profileOpt.map(InstructorProfileEntity::getQualification).orElse(instructor.getQualification()));
        map.put("experience", profileOpt.map(InstructorProfileEntity::getExperience).orElse(instructor.getExperience()));
        map.put("bio", profileOpt.map(InstructorProfileEntity::getBio).orElse(instructor.getAbout()));
        map.put("status", instructor.getStatus());
        map.put("createdAt", instructor.getCreatedAt() != null ? instructor.getCreatedAt().toString() : null);
        return map;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserEntity createInstructor(HttpServletRequest request, @RequestBody UserEntity instructor) {
        UserEntity actor = accessService.require(request, "admin");

        if (instructor.getEmail() == null || instructor.getEmail().isBlank() || !instructor.getEmail().contains("@")
                || instructor.getName() == null || instructor.getName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Instructor name and a valid email are required.");
        }
        String initialPassword = instructor.getPassword();
        if (initialPassword == null || initialPassword.length() < 8
                || java.util.Set.of("password123", "edlearn123").contains(initialPassword)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Set a non-default initial password of at least 8 characters.");
        }
        String email = instructor.getEmail().trim();
        if (userRepository.existsByEmailIgnoreCase(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already exists: " + email);
        }
        if (instructor.getInstructorId() != null && !instructor.getInstructorId().isBlank()) {
            if (userRepository.existsByInstructorIdIgnoreCase(instructor.getInstructorId().trim())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Instructor ID already exists: " + instructor.getInstructorId());
            }
        }

        instructor.setId(null);
        instructor.setRole("teacher");
        instructor.setEmail(email);
        String instCode = actor.getInstituteCode() != null && !actor.getInstituteCode().isBlank() ? actor.getInstituteCode() : "INST-2025";
        instructor.setInstituteCode(instCode);
        instructor.setInstituteName(actor.getInstituteName() != null ? actor.getInstituteName() : "EduChain Campus");
        instructor.setPassword(PASSWORD_ENCODER.encode(initialPassword));
        if (instructor.getUserId() == null || instructor.getUserId().isBlank()) {
            instructor.setUserId("ins_" + System.currentTimeMillis());
        }

        String name = instructor.getName() != null && !instructor.getName().isBlank() ? instructor.getName().trim() : instructor.getFullName();
        if (name == null || name.isBlank()) name = "Instructor";
        instructor.setName(name.trim());

        if (instructor.getStatus() == null || instructor.getStatus().isBlank()) {
            instructor.setStatus("Active");
        }
        if (instructor.getDepartment() == null || instructor.getDepartment().isBlank()) {
            instructor.setDepartment("Computer Science");
        }
        if (instructor.getInstructorId() == null || instructor.getInstructorId().isBlank()) {
            instructor.setInstructorId("INS-" + (1000 + new Random().nextInt(9000)));
        }
        if (instructor.getDesignation() == null || instructor.getDesignation().isBlank()) {
            instructor.setDesignation("Instructor");
        }
        if (instructor.getQualification() == null || instructor.getQualification().isBlank()) {
            instructor.setQualification("Master's Degree");
        }
        if (instructor.getExperience() == null || instructor.getExperience().isBlank()) {
            instructor.setExperience("3+ Years");
        }
        if (instructor.getPhone() == null || instructor.getPhone().isBlank()) {
            instructor.setPhone("+91 98765 00000");
        }
        if (instructor.getAddress() == null || instructor.getAddress().isBlank()) {
            instructor.setAddress("Campus Faculty Quarters");
        }
        if (instructor.getJoiningDate() == null || instructor.getJoiningDate().isBlank()) {
            instructor.setJoiningDate("2024-01-15");
        }
        if (instructor.getAbout() == null || instructor.getAbout().isBlank()) {
            instructor.setAbout("Passionate instructor in " + instructor.getDepartment());
        }

        UserEntity savedInstructor;
        try {
            savedInstructor = userRepository.save(instructor);
        } catch (DataIntegrityViolationException ex) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "An account with this email already exists.", ex);
        }

        // Save into instructor_profiles table
        try {
            InstructorProfileEntity profile = new InstructorProfileEntity();
            profile.setUser(savedInstructor);
            profile.setQualification(savedInstructor.getQualification());
            profile.setExpertise(savedInstructor.getDepartment());
            profile.setExperience(savedInstructor.getExperience());
            profile.setBio(savedInstructor.getAbout());
            instructorProfileRepository.save(profile);
        } catch (Exception ignored) {}

        return savedInstructor;
    }

    @PutMapping("/{id}")
    public UserEntity updateInstructor(HttpServletRequest request, @PathVariable String id, @RequestBody UserEntity updated) {
        accessService.require(request, "admin");
        UserEntity instructor = findInstructor(id);

        if (updated.getName() != null && !updated.getName().isBlank()) {
            instructor.setName(updated.getName().trim());
        } else if (updated.getFullName() != null && !updated.getFullName().isBlank()) {
            instructor.setName(updated.getFullName().trim());
        }
        if (updated.getEmail() != null && !updated.getEmail().isBlank()) instructor.setEmail(updated.getEmail().trim());
        if (updated.getInstructorId() != null && !updated.getInstructorId().isBlank()) instructor.setInstructorId(updated.getInstructorId().trim());
        if (updated.getDepartment() != null && !updated.getDepartment().isBlank()) instructor.setDepartment(updated.getDepartment().trim());
        if (updated.getDesignation() != null && !updated.getDesignation().isBlank()) instructor.setDesignation(updated.getDesignation().trim());
        if (updated.getQualification() != null && !updated.getQualification().isBlank()) instructor.setQualification(updated.getQualification().trim());
        if (updated.getExperience() != null && !updated.getExperience().isBlank()) instructor.setExperience(updated.getExperience().trim());
        if (updated.getPhone() != null && !updated.getPhone().isBlank()) instructor.setPhone(updated.getPhone().trim());
        if (updated.getAddress() != null && !updated.getAddress().isBlank()) instructor.setAddress(updated.getAddress().trim());
        if (updated.getProfileImage() != null && !updated.getProfileImage().isBlank()) instructor.setProfileImage(updated.getProfileImage().trim());
        if (updated.getAbout() != null && !updated.getAbout().isBlank()) instructor.setAbout(updated.getAbout().trim());
        if (updated.getStatus() != null && !updated.getStatus().isBlank()) instructor.setStatus(updated.getStatus().trim());
        if (updated.getPassword() != null && !updated.getPassword().isBlank()) {
            if (updated.getPassword().length() < 6) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password must contain at least 6 characters.");
            instructor.setPassword(PASSWORD_ENCODER.encode(updated.getPassword()));
        }

        UserEntity saved = userRepository.save(instructor);

        // Update profile in instructor_profiles table
        try {
            InstructorProfileEntity profile = instructorProfileRepository.findByUserId(saved.getId())
                    .orElseGet(() -> {
                        InstructorProfileEntity p = new InstructorProfileEntity();
                        p.setUser(saved);
                        return p;
                    });
            profile.setQualification(saved.getQualification());
            profile.setExpertise(saved.getDepartment());
            profile.setExperience(saved.getExperience());
            profile.setBio(saved.getAbout());
            instructorProfileRepository.save(profile);
        } catch (Exception ignored) {}

        return saved;
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> updateStatus(HttpServletRequest request, @PathVariable String id, @RequestBody Map<String, Object> body) {
        accessService.require(request, "admin");
        UserEntity instructor = findInstructor(id);
        String status = (String) body.get("status");
        if (status != null && !status.isBlank()) {
            instructor.setStatus(status.trim());
            userRepository.save(instructor);
        }
        return ResponseEntity.ok(Map.of("success", true, "id", id, "status", instructor.getStatus()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteInstructor(HttpServletRequest request, @PathVariable String id) {
        accessService.require(request, "admin");
        UserEntity instructor = findInstructor(id);
        try {
            instructorProfileRepository.deleteByUserId(instructor.getId());
        } catch (Exception ignored) {}
        userRepository.delete(instructor);
        return ResponseEntity.ok(Map.of("success", true, "message", "Instructor deleted successfully", "id", id));
    }
}
