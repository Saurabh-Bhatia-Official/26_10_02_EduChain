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
        stats.put("activeClasses", 18);
        stats.put("attendanceRate", 91.5);
        stats.put("systemStatus", "Healthy & Connected");

        List<UserEntity> recentStudents = userRepository.findByRoleIgnoreCaseOrderByCreatedAtDesc("student");
        if (recentStudents.isEmpty()) recentStudents = userRepository.findByRoleIgnoreCase("student");
        if (recentStudents.size() > 5) recentStudents = recentStudents.subList(0, 5);
        stats.put("recentStudents", recentStudents);

        List<UserEntity> recentInstructors = userRepository.findByRoleIgnoreCaseOrderByCreatedAtDesc("teacher");
        if (recentInstructors.isEmpty()) recentInstructors = userRepository.findByRoleIgnoreCase("teacher");
        if (recentInstructors.size() > 5) recentInstructors = recentInstructors.subList(0, 5);
        stats.put("recentInstructors", recentInstructors);

        return ResponseEntity.ok(stats);
    }

    @GetMapping("/instructor/{id}")
    public ResponseEntity<Map<String, Object>> getInstructorDashboardStats(@PathVariable String id) {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("assignedCourses", 4);
        stats.put("totalStudents", userRepository.countByRoleIgnoreCase("student"));
        stats.put("upcomingLectures", 3);
        stats.put("pendingAssignments", 12);
        stats.put("averageClassRating", 4.8);

        List<UserEntity> students = userRepository.findByRoleIgnoreCaseOrderByCreatedAtDesc("student");
        if (students.isEmpty()) students = userRepository.findByRoleIgnoreCase("student");
        if (students.size() > 6) students = students.subList(0, 6);
        stats.put("enrolledStudents", students);

        return ResponseEntity.ok(stats);
    }
}
