package com.edlearn.backend.controller;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/instructors")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class InstructorController {

    private final UserRepository userRepository;

    public InstructorController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    private UserEntity findInstructor(String id) {
        try {
            UUID uuid = UUID.fromString(id);
            Optional<UserEntity> byId = userRepository.findById(uuid);
            if (byId.isPresent() && "teacher".equalsIgnoreCase(byId.get().getRole())) {
                return byId.get();
            }
        } catch (Exception ignored) {}

        return userRepository.findByInstructorIdIgnoreCase(id)
                .or(() -> userRepository.findByUserId(id))
                .or(() -> userRepository.findByEmailIgnoreCase(id))
                .filter(u -> "teacher".equalsIgnoreCase(u.getRole()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Instructor not found: " + id));
    }

    @GetMapping
    public List<UserEntity> getAllInstructors(@RequestParam(required = false) String search) {
        List<UserEntity> list = userRepository.findByRoleIgnoreCaseOrderByCreatedAtDesc("teacher");
        if (list.isEmpty()) {
            list = userRepository.findByRoleIgnoreCase("teacher");
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
    public UserEntity getInstructor(@PathVariable String id) {
        return findInstructor(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserEntity createInstructor(@RequestBody UserEntity instructor) {
        if (instructor.getEmail() != null && !instructor.getEmail().isBlank()) {
            if (userRepository.existsByEmailIgnoreCase(instructor.getEmail().trim())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already exists: " + instructor.getEmail());
            }
        }
        if (instructor.getInstructorId() != null && !instructor.getInstructorId().isBlank()) {
            if (userRepository.existsByInstructorIdIgnoreCase(instructor.getInstructorId().trim())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Instructor ID already exists: " + instructor.getInstructorId());
            }
        }

        instructor.setId(null);
        instructor.setRole("teacher");
        if (instructor.getUserId() == null || instructor.getUserId().isBlank()) {
            instructor.setUserId("ins_" + System.currentTimeMillis());
        }

        // Validate and safeguard Name
        String name = instructor.getName();
        if (name == null || name.isBlank()) {
            name = instructor.getFullName();
        }
        if (name == null || name.isBlank()) {
            name = "Faculty Member";
        }
        instructor.setName(name.trim());

        if (instructor.getPassword() == null || instructor.getPassword().isBlank()) {
            instructor.setPassword("password123");
        }
        if (instructor.getInstituteCode() == null || instructor.getInstituteCode().isBlank()) {
            instructor.setInstituteCode("INST-2025");
        }
        if (instructor.getInstituteName() == null || instructor.getInstituteName().isBlank()) {
            instructor.setInstituteName("Apex Institute of Technology");
        }
        if (instructor.getStatus() == null || instructor.getStatus().isBlank()) {
            instructor.setStatus("Active");
        }
        if (instructor.getDepartment() == null || instructor.getDepartment().isBlank()) {
            instructor.setDepartment("Computer Science");
        }
        if (instructor.getInstructorId() == null || instructor.getInstructorId().isBlank()) {
            instructor.setInstructorId("INS-" + (1000 + new java.util.Random().nextInt(9000)));
        }
        if (instructor.getDesignation() == null || instructor.getDesignation().isBlank()) {
            instructor.setDesignation("Assistant Professor");
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
            instructor.setAbout("Passionate faculty member in " + instructor.getDepartment());
        }

        return userRepository.save(instructor);
    }

    @PutMapping("/{id}")
    public UserEntity updateInstructor(@PathVariable String id, @RequestBody UserEntity updated) {
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
        if (updated.getJoiningDate() != null && !updated.getJoiningDate().isBlank()) instructor.setJoiningDate(updated.getJoiningDate().trim());
        if (updated.getAbout() != null && !updated.getAbout().isBlank()) instructor.setAbout(updated.getAbout().trim());
        if (updated.getStatus() != null && !updated.getStatus().isBlank()) instructor.setStatus(updated.getStatus().trim());

        return userRepository.save(instructor);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteInstructor(@PathVariable String id) {
        UserEntity instructor = findInstructor(id);
        userRepository.delete(instructor);
        return ResponseEntity.ok(Map.of("success", true, "message", "Instructor deleted successfully", "id", id));
    }
}
