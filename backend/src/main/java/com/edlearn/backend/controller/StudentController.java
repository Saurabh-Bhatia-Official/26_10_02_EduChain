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
@RequestMapping("/api/students")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class StudentController {

    private final UserRepository userRepository;

    public StudentController(UserRepository userRepository) {
        this.userRepository = userRepository;
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
    public List<UserEntity> getAllStudents(@RequestParam(required = false) String search) {
        List<UserEntity> list = userRepository.findByRoleIgnoreCaseOrderByCreatedAtDesc("student");
        if (list.isEmpty()) {
            list = userRepository.findByRoleIgnoreCase("student");
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
    public UserEntity getStudent(@PathVariable String id) {
        return findStudent(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserEntity createStudent(@RequestBody UserEntity student) {
        if (student.getEmail() != null && !student.getEmail().isBlank()) {
            if (userRepository.existsByEmailIgnoreCase(student.getEmail().trim())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already exists: " + student.getEmail());
            }
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
        if (student.getPassword() == null || student.getPassword().isBlank()) {
            student.setPassword("password123");
        }
        if (student.getInstituteCode() == null || student.getInstituteCode().isBlank()) {
            student.setInstituteCode("INST-2025");
        }
        if (student.getStatus() == null || student.getStatus().isBlank()) {
            student.setStatus("Active");
        }
        return userRepository.save(student);
    }

    @PutMapping("/{id}")
    public UserEntity updateStudent(@PathVariable String id, @RequestBody UserEntity updated) {
        UserEntity student = findStudent(id);

        if (updated.getName() != null) student.setName(updated.getName());
        if (updated.getEmail() != null) student.setEmail(updated.getEmail());
        if (updated.getRollNumber() != null) student.setRollNumber(updated.getRollNumber());
        if (updated.getClassName() != null) student.setClassName(updated.getClassName());
        if (updated.getCourse() != null) student.setCourse(updated.getCourse());
        if (updated.getSemester() != null) student.setSemester(updated.getSemester());
        if (updated.getPhone() != null) student.setPhone(updated.getPhone());
        if (updated.getAddress() != null) student.setAddress(updated.getAddress());
        if (updated.getFatherName() != null) student.setFatherName(updated.getFatherName());
        if (updated.getFatherPhone() != null) student.setFatherPhone(updated.getFatherPhone());
        if (updated.getFatherEmail() != null) student.setFatherEmail(updated.getFatherEmail());
        if (updated.getMotherName() != null) student.setMotherName(updated.getMotherName());
        if (updated.getMotherPhone() != null) student.setMotherPhone(updated.getMotherPhone());
        if (updated.getMotherEmail() != null) student.setMotherEmail(updated.getMotherEmail());
        if (updated.getGender() != null) student.setGender(updated.getGender());
        if (updated.getDob() != null) student.setDob(updated.getDob());
        if (updated.getStatus() != null) student.setStatus(updated.getStatus());

        return userRepository.save(student);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteStudent(@PathVariable String id) {
        UserEntity student = findStudent(id);
        userRepository.delete(student);
        return ResponseEntity.ok(Map.of("success", true, "message", "Student deleted successfully", "id", id));
    }
}
