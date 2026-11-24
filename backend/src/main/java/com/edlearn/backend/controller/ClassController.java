package com.edlearn.backend.controller;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.service.ClassService;
import com.edlearn.backend.service.PortalAccessService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/classes")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class ClassController {

    private final ClassService classService;
    private final PortalAccessService accessService;

    public ClassController(ClassService classService, PortalAccessService accessService) {
        this.classService = classService;
        this.accessService = accessService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> createClass(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        UserEntity actor = accessService.require(request, "teacher", "instructor", "admin");
        return classService.createClass(actor, body);
    }

    @GetMapping
    public List<Map<String, Object>> getClasses(HttpServletRequest request) {
        UserEntity actor = accessService.require(request, "admin", "teacher", "instructor", "student");
        if ("admin".equalsIgnoreCase(actor.getRole())) {
            return classService.getAllClassesForAdmin();
        } else if ("teacher".equalsIgnoreCase(actor.getRole()) || "instructor".equalsIgnoreCase(actor.getRole())) {
            return classService.getInstructorClasses(actor.getId());
        } else {
            return classService.getStudentClasses(actor);
        }
    }

    @GetMapping("/upcoming")
    public List<Map<String, Object>> getUpcomingClasses(HttpServletRequest request) {
        List<Map<String, Object>> list = getClasses(request);
        return list.stream()
                .filter(c -> "Upcoming".equalsIgnoreCase((String) c.get("status")) || "Live".equalsIgnoreCase((String) c.get("status")))
                .collect(Collectors.toList());
    }

    @GetMapping("/history")
    public List<Map<String, Object>> getCompletedClasses(HttpServletRequest request) {
        List<Map<String, Object>> list = getClasses(request);
        return list.stream()
                .filter(c -> "Completed".equalsIgnoreCase((String) c.get("status")))
                .collect(Collectors.toList());
    }

    @PostMapping(value = "/generate-meet", consumes = {org.springframework.http.MediaType.APPLICATION_JSON_VALUE, org.springframework.http.MediaType.ALL_VALUE})
    public Map<String, Object> generateMeetLink(HttpServletRequest request, @RequestBody(required = false) Map<String, Object> body) {
        UserEntity actor = accessService.require(request, "teacher", "instructor", "admin");
        return classService.generateGoogleMeetLink(actor, body != null ? body : Map.of());
    }

    @PutMapping("/{id}")
    public Map<String, Object> updateClass(HttpServletRequest request, @PathVariable UUID id, @RequestBody Map<String, Object> body) {
        UserEntity actor = accessService.require(request, "teacher", "instructor", "admin");
        return classService.updateClass(actor, id, body);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteClass(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity actor = accessService.require(request, "teacher", "instructor", "admin");
        classService.deleteClass(actor, id);
    }

    @PostMapping("/{id}/join")
    public Map<String, Object> joinClass(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity actor = accessService.require(request, "student", "teacher", "instructor", "admin");
        return classService.joinClass(actor, id);
    }
}
