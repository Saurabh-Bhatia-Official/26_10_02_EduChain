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
        if (instructor.getPassword() == null || instructor.getPassword().isBlank()) {
            instructor.setPassword("password123");
        }
        if (instructor.getInstituteCode() == null || instructor.getInstituteCode().isBlank()) {
            instructor.setInstituteCode("INST-2025");
        }
        if (instructor.getStatus() == null || instructor.getStatus().isBlank()) {
            instructor.setStatus("Active");
        }
        return userRepository.save(instructor);
    }

    @PutMapping("/{id}")
    public UserEntity updateInstructor(@PathVariable String id, @RequestBody UserEntity updated) {
        UserEntity instructor = findInstructor(id);

        if (updated.getName() != null) instructor.setName(updated.getName());
        if (updated.getEmail() != null) instructor.setEmail(updated.getEmail());
        if (updated.getInstructorId() != null) instructor.setInstructorId(updated.getInstructorId());
        if (updated.getDepartment() != null) instructor.setDepartment(updated.getDepartment());
        if (updated.getDesignation() != null) instructor.setDesignation(updated.getDesignation());
        if (updated.getQualification() != null) instructor.setQualification(updated.getQualification());
        if (updated.getExperience() != null) instructor.setExperience(updated.getExperience());
        if (updated.getPhone() != null) instructor.setPhone(updated.getPhone());
        if (updated.getAddress() != null) instructor.setAddress(updated.getAddress());
        if (updated.getJoiningDate() != null) instructor.setJoiningDate(updated.getJoiningDate());
        if (updated.getAbout() != null) instructor.setAbout(updated.getAbout());
        if (updated.getStatus() != null) instructor.setStatus(updated.getStatus());

        return userRepository.save(instructor);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteInstructor(@PathVariable String id) {
        UserEntity instructor = findInstructor(id);
        userRepository.delete(instructor);
        return ResponseEntity.ok(Map.of("success", true, "message", "Instructor deleted successfully", "id", id));
    }
}
