package com.edlearn.backend.controller;

import com.edlearn.backend.service.ClassroomService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/public/classrooms")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class PublicClassroomController {

    private final ClassroomService classroomService;

    public PublicClassroomController(ClassroomService classroomService) {
        this.classroomService = classroomService;
    }

    @GetMapping
    public List<Map<String, Object>> searchPublicClassrooms(@RequestParam(required = false) String search) {
        return classroomService.searchPublicClassrooms(search);
    }
}
