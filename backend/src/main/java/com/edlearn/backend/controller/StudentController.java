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

        // Validate and safeguard Name
        String name = student.getName();
        if (name == null || name.isBlank()) {
            name = student.getFullName();
        }
        if (name == null || name.isBlank()) {
            name = "Student";
        }
        student.setName(name.trim());

        if (student.getPassword() == null || student.getPassword().isBlank()) {
            student.setPassword("password123");
        }
        if (student.getInstituteCode() == null || student.getInstituteCode().isBlank()) {
            student.setInstituteCode("INST-2025");
        }
        if (student.getInstituteName() == null || student.getInstituteName().isBlank()) {
            student.setInstituteName("Apex Institute of Technology");
        }
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
        if (student.getPhone() == null || student.getPhone().isBlank()) {
            student.setPhone("+91 98765 00000");
        }
        if (student.getGender() == null || student.getGender().isBlank()) {
            student.setGender("Not Specified");
        }
        if (student.getDob() == null || student.getDob().isBlank()) {
            student.setDob("2005-01-01");
        }
        if (student.getAddress() == null || student.getAddress().isBlank()) {
            student.setAddress("Campus Residential");
        }
        if (student.getFatherName() == null || student.getFatherName().isBlank()) {
            student.setFatherName("Guardian of " + student.getName());
        }
        if (student.getFatherPhone() == null || student.getFatherPhone().isBlank()) {
            student.setFatherPhone(student.getPhone());
        }
        if (student.getFatherEmail() == null || student.getFatherEmail().isBlank()) {
            student.setFatherEmail(student.getEmail() != null && student.getEmail().contains("@") ? student.getEmail().replace("@", ".parent@") : "parent@example.com");
        }
        if (student.getMotherName() == null || student.getMotherName().isBlank()) {
            student.setMotherName("Guardian");
        }
        if (student.getMotherPhone() == null || student.getMotherPhone().isBlank()) {
            student.setMotherPhone(student.getPhone());
        }
        if (student.getMotherEmail() == null || student.getMotherEmail().isBlank()) {
            student.setMotherEmail(student.getEmail() != null && student.getEmail().contains("@") ? student.getEmail().replace("@", ".mother@") : "mother@example.com");
        }

        return userRepository.save(student);
    }

    @PutMapping("/{id}")
    public UserEntity updateStudent(@PathVariable String id, @RequestBody UserEntity updated) {
        UserEntity student = findStudent(id);

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

        return userRepository.save(student);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteStudent(@PathVariable String id) {
        UserEntity student = findStudent(id);
        userRepository.delete(student);
        return ResponseEntity.ok(Map.of("success", true, "message", "Student deleted successfully", "id", id));
    }
}
