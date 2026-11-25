package com.edlearn.backend.controller;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.service.CourseBatchService;
import com.edlearn.backend.service.PortalAccessService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class CourseBatchController {

    private final CourseBatchService service;
    private final PortalAccessService accessService;

    public CourseBatchController(CourseBatchService service, PortalAccessService accessService) {
        this.service = service;
        this.accessService = accessService;
    }

    // ================= Courses =================
    @GetMapping("/courses")
    public List<Map<String, Object>> getCourses(HttpServletRequest request) {
        UserEntity user = accessService.require(request, "admin", "teacher", "instructor", "student");
        return service.getAllCourses(user.getInstituteCode());
    }

    @GetMapping("/courses/{id}")
    public Map<String, Object> getCourseById(HttpServletRequest request, @PathVariable UUID id) {
        accessService.require(request, "admin", "teacher", "instructor", "student");
        return service.getCourseById(id);
    }

    @PostMapping("/courses")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> createCourse(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        UserEntity actor = accessService.require(request, "admin", "teacher", "instructor");
        return service.createCourse(actor, body);
    }

    @PutMapping("/courses/{id}")
    public Map<String, Object> updateCourse(HttpServletRequest request, @PathVariable UUID id, @RequestBody Map<String, Object> body) {
        accessService.require(request, "admin", "teacher", "instructor");
        return service.updateCourse(id, body);
    }

    @DeleteMapping("/courses/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteCourse(HttpServletRequest request, @PathVariable UUID id) {
        accessService.require(request, "admin", "teacher", "instructor");
        service.deleteCourse(id);
    }

    // ================= Batches =================
    @GetMapping("/courses/{courseId}/batches")
    public List<Map<String, Object>> getBatchesForCourse(HttpServletRequest request, @PathVariable UUID courseId) {
        accessService.require(request, "admin", "teacher", "instructor", "student");
        return service.getBatchesForCourse(courseId);
    }

    @GetMapping("/batches")
    public List<Map<String, Object>> getAllBatches(HttpServletRequest request) {
        UserEntity user = accessService.require(request, "admin", "teacher", "instructor", "student");
        return service.getAllBatches(user.getInstituteCode());
    }

    @PostMapping("/batches")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> createBatch(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        UserEntity actor = accessService.require(request, "admin", "teacher", "instructor");
        return service.createBatch(actor, body);
    }

    // ================= Enrollments =================
    @PostMapping("/enrollments")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> enrollStudent(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        accessService.require(request, "admin", "teacher", "instructor");
        return service.enrollStudent(body);
    }

    @GetMapping("/enrollments/student/{studentId}")
    public List<Map<String, Object>> getStudentEnrollments(HttpServletRequest request, @PathVariable UUID studentId) {
        accessService.require(request, "admin", "teacher", "instructor", "student");
        return service.getStudentEnrollments(studentId);
    }

    @GetMapping("/enrollments/my")
    public List<Map<String, Object>> getMyEnrollments(HttpServletRequest request) {
        UserEntity student = accessService.require(request, "student");
        return service.getStudentEnrollments(student.getId());
    }

    @GetMapping("/courses/{courseId}/enrollments")
    public List<Map<String, Object>> getCourseEnrollments(HttpServletRequest request, @PathVariable UUID courseId) {
        accessService.require(request, "admin", "teacher", "instructor");
        return service.getEnrolledStudentsForCourse(courseId);
    }

    @GetMapping("/batches/{batchId}/enrollments")
    public List<Map<String, Object>> getBatchEnrollments(HttpServletRequest request, @PathVariable UUID batchId) {
        accessService.require(request, "admin", "teacher", "instructor");
        return service.getEnrolledStudentsForBatch(batchId);
    }
}
