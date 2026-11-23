package com.edlearn.backend.controller;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.InstituteRepository;
import com.edlearn.backend.repository.UserRepository;
import com.edlearn.backend.repository.ClassroomRepository;
import com.edlearn.backend.repository.ClassroomMemberRepository;
import com.edlearn.backend.service.PortalAccessService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class DashboardController {

    private final UserRepository userRepository;
    private final InstituteRepository instituteRepository;
    private final ClassroomRepository classroomRepository;
    private final ClassroomMemberRepository classroomMemberRepository;
    private final PortalAccessService accessService;

    public DashboardController(UserRepository userRepository, InstituteRepository instituteRepository,
                               ClassroomRepository classroomRepository, ClassroomMemberRepository classroomMemberRepository,
                               PortalAccessService accessService) {
        this.userRepository = userRepository;
        this.instituteRepository = instituteRepository;
        this.classroomRepository = classroomRepository;
        this.classroomMemberRepository = classroomMemberRepository;
        this.accessService = accessService;
    }

    @GetMapping("/admin")
    public ResponseEntity<Map<String, Object>> getAdminDashboardStats(HttpServletRequest request) {
        UserEntity actor = accessService.require(request, "admin");
        String instituteCode = actor.getInstituteCode();
        Map<String, Object> stats = new LinkedHashMap<>();
        long studentCount = userRepository.countByInstituteCodeIgnoreCaseAndRoleIgnoreCase(instituteCode, "student");
        long instructorCount = userRepository.countByInstituteCodeIgnoreCaseAndRoleIgnoreCase(instituteCode, "teacher");
        long instituteCount = instituteRepository.findByInstituteCodeIgnoreCase(instituteCode).isPresent() ? 1 : 0;
        long activeClasses = classroomRepository.findAll().stream()
                .filter(c -> !c.isArchived() && instituteCode != null && instituteCode.equalsIgnoreCase(c.getInstituteCode())).count();

        stats.put("totalStudents", studentCount);
        stats.put("totalInstructors", instructorCount);
        stats.put("totalInstitutes", instituteCount);
        stats.put("activeClasses", activeClasses);
        stats.put("attendanceRate", 0.0);
        stats.put("systemStatus", "Connected");

        List<UserEntity> recentStudents = userRepository.findByInstituteCodeIgnoreCaseAndRoleIgnoreCaseOrderByCreatedAtDesc(instituteCode, "student");
        if (recentStudents.size() > 5) recentStudents = recentStudents.subList(0, 5);
        stats.put("recentStudents", recentStudents);

        List<UserEntity> recentInstructors = userRepository.findByInstituteCodeIgnoreCaseAndRoleIgnoreCaseOrderByCreatedAtDesc(instituteCode, "teacher");
        if (recentInstructors.size() > 5) recentInstructors = recentInstructors.subList(0, 5);
        stats.put("recentInstructors", recentInstructors);

        return ResponseEntity.ok(stats);
    }

    @GetMapping("/instructor/{id}")
    public ResponseEntity<Map<String, Object>> getInstructorDashboardStats(HttpServletRequest request, @PathVariable String id) {
        UserEntity actor = accessService.require(request, "teacher", "admin");
        if ("teacher".equalsIgnoreCase(actor.getRole())
                && !actor.getId().toString().equalsIgnoreCase(id)
                && (actor.getUserId() == null || !actor.getUserId().equalsIgnoreCase(id))) {
            return ResponseEntity.notFound().build();
        }
        String instituteCode = actor.getInstituteCode();
        List<com.edlearn.backend.model.ClassroomEntity> classrooms = classroomRepository.findAllClassroomsByUserId(actor.getId()).stream()
                .filter(c -> !c.isArchived() && instituteCode != null && instituteCode.equalsIgnoreCase(c.getInstituteCode()))
                .toList();
        Set<UUID> studentIds = new HashSet<>();
        for (var classroom : classrooms) {
            for (var membership : classroomMemberRepository.findByClassroomIdAndStatus(classroom.getId(), "ACTIVE")) {
                if ("STUDENT".equalsIgnoreCase(membership.getRole()) && membership.getUser() != null) {
                    studentIds.add(membership.getUser().getId());
                }
            }
        }
        List<UserEntity> students = studentIds.stream().map(userRepository::findById).flatMap(Optional::stream).toList();
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("assignedCourses", classrooms.size());
        stats.put("totalStudents", students.size());
        stats.put("upcomingLectures", 0);
        stats.put("pendingAssignments", 0);
        stats.put("averageClassRating", 0.0);
        if (students.size() > 6) students = students.subList(0, 6);
        stats.put("enrolledStudents", students);

        return ResponseEntity.ok(stats);
    }
}
