package com.edlearn.backend.controller;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.service.ExamQuestionService;
import com.edlearn.backend.service.PortalAccessService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/exam-questions")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class ExamQuestionController {
    private final ExamQuestionService questionService;
    private final PortalAccessService accessService;

    public ExamQuestionController(ExamQuestionService questionService, PortalAccessService accessService) {
        this.questionService = questionService;
        this.accessService = accessService;
    }

    @GetMapping
    public List<Map<String, Object>> list(HttpServletRequest request, @RequestParam Map<String, String> filters) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        return questionService.list(teacher, filters);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> create(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        return questionService.create(teacher, body);
    }

    @GetMapping("/{id}")
    public Map<String, Object> get(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        return questionService.get(teacher, id);
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(HttpServletRequest request, @PathVariable UUID id, @RequestBody Map<String, Object> body) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        return questionService.update(teacher, id, body);
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        questionService.delete(teacher, id);
        return Map.of("success", true);
    }

    @GetMapping("/{id}/versions")
    public List<Map<String, Object>> versions(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        return questionService.history(teacher, id);
    }
}
