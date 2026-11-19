package com.edlearn.backend.controller;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.InstituteRepository;
import com.edlearn.backend.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class DashboardController {

    private final UserRepository userRepository;
    private final InstituteRepository instituteRepository;

    public DashboardController(UserRepository userRepository, InstituteRepository instituteRepository) {
        this.userRepository = userRepository;
        this.instituteRepository = instituteRepository;
    }

    @GetMapping("/admin")
    public ResponseEntity<Map<String, Object>> getAdminDashboardStats() {
        Map<String, Object> stats = new LinkedHashMap<>();
        long studentCount = userRepository.countByRoleIgnoreCase("student");
        long instructorCount = userRepository.countByRoleIgnoreCase("teacher");
        long instituteCount = instituteRepository.count();

        stats.put("totalStudents", studentCount);
        stats.put("totalInstructors", instructorCount);
        stats.put("totalInstitutes", instituteCount);
        stats.put("systemStatus", "Healthy & Connected");

        List<UserEntity> recentStudents = userRepository.findByRoleIgnoreCaseOrderByCreatedAtDesc("student");
        if (recentStudents.size() > 5) recentStudents = recentStudents.subList(0, 5);
        stats.put("recentStudents", recentStudents);

        List<UserEntity> recentInstructors = userRepository.findByRoleIgnoreCaseOrderByCreatedAtDesc("teacher");
        if (recentInstructors.size() > 5) recentInstructors = recentInstructors.subList(0, 5);
        stats.put("recentInstructors", recentInstructors);

        return ResponseEntity.ok(stats);
    }

    @GetMapping("/instructor/{id}")
    public ResponseEntity<Map<String, Object>> getInstructorDashboardStats(@PathVariable String id) {
        Map<String, Object> stats = new LinkedHashMap<>();
        // Detailed classroom metrics are omitted until classroom ownership is backed by persisted relations.
        stats.put("enrolledStudents", List.of());

        return ResponseEntity.ok(stats);
    }
}
