package com.edlearn.backend.controller;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.service.ExamService;
import com.edlearn.backend.service.PortalAccessService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/portal/exams")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class ExamController {

    private final ExamService examService;
    private final PortalAccessService accessService;

    public ExamController(ExamService examService, PortalAccessService accessService) {
        this.examService = examService;
        this.accessService = accessService;
    }

    @GetMapping
    public List<Map<String, Object>> getExams(HttpServletRequest request) {
        UserEntity user = accessService.require(request, "admin", "teacher", "student");
        return examService.getExams(user);
    }

    @GetMapping("/{id}")
    public Map<String, Object> getExamDetails(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity user = accessService.require(request, "admin", "teacher", "student");
        return examService.getExamDetails(user, id);
    }

    @PostMapping("/{id}/start")
    public Map<String, Object> startAttempt(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity student = accessService.require(request, "student");
        return examService.startAttempt(student, id);
    }

    @PostMapping("/{id}/save-answer")
    public Map<String, Object> saveAnswer(HttpServletRequest request, @PathVariable UUID id,
                                          @RequestBody Map<String, Object> body) {
        UserEntity student = accessService.require(request, "student");
        return examService.saveAnswer(student, id, body);
    }

    @PostMapping("/{id}/submit")
    public Map<String, Object> submitExam(HttpServletRequest request, @PathVariable UUID id,
                                          @RequestBody(required = false) Map<String, Object> body) {
        UserEntity student = accessService.require(request, "student");
        return examService.submitExam(student, id, body);
    }

    @GetMapping("/{id}/attempt")
    public Map<String, Object> getAttempt(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity user = accessService.require(request, "student", "teacher", "admin");
        return examService.getStudentAttempt(user, id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> createExam(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        return examService.createExam(teacher, body);
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> deleteExam(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        examService.deleteExam(teacher, id);
        return Map.of("success", true, "message", "Examination deleted successfully.");
    }

    @PutMapping("/{id}/release-results")
    public Map<String, Object> releaseResults(HttpServletRequest request, @PathVariable UUID id,
                                              @RequestBody Map<String, Object> body) {
        UserEntity user = accessService.require(request, "admin", "teacher");
        boolean release = Boolean.TRUE.equals(body.get("release"));
        return examService.releaseResults(user, id, release);
    }

    @GetMapping("/{id}/attempts")
    public List<Map<String, Object>> getExamAttempts(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity user = accessService.require(request, "admin", "teacher");
        return examService.getExamAttempts(user, id);
    }
}
