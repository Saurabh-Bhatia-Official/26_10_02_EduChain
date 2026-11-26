package com.edlearn.backend.controller;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.service.LiveClassService;
import com.edlearn.backend.service.PortalAccessService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/live-classes")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class LiveClassController {

    private final LiveClassService liveClassService;
    private final PortalAccessService accessService;

    public LiveClassController(LiveClassService liveClassService, PortalAccessService accessService) {
        this.liveClassService = liveClassService;
        this.accessService = accessService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> scheduleLiveClass(HttpServletRequest request,
                                                 @RequestParam UUID classroomId,
                                                 @RequestBody Map<String, Object> body) {
        UserEntity host = accessService.require(request, "teacher", "admin");
        return liveClassService.scheduleLiveClass(host, classroomId, body);
    }

    @PutMapping("/{id}")
    public Map<String, Object> updateLiveClass(HttpServletRequest request,
                                               @PathVariable UUID id,
                                               @RequestBody Map<String, Object> body) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        return liveClassService.updateLiveClass(teacher, id, body);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteLiveClass(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        liveClassService.deleteLiveClass(teacher, id);
    }

    @GetMapping("/classroom/{classroomId}")
    public List<Map<String, Object>> getClassroomLiveClasses(HttpServletRequest request,
                                                             @PathVariable UUID classroomId) {
        UserEntity user = accessService.require(request, "teacher", "student", "admin");
        return liveClassService.getClassroomLiveClasses(user, classroomId);
    }

    @GetMapping(value = {"", "/upcoming"})
    public List<Map<String, Object>> getUpcomingForUser(HttpServletRequest request) {
        UserEntity user = accessService.require(request, "teacher", "student", "admin");
        return liveClassService.getUpcomingForUser(user);
    }

    @PostMapping("/{id}/join")
    public Map<String, Object> joinClass(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity user = accessService.require(request, "teacher", "student", "admin");
        return liveClassService.joinClass(user, id);
    }

    @PostMapping("/{id}/leave")
    public Map<String, Object> leaveClass(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity user = accessService.require(request, "teacher", "student", "admin");
        return liveClassService.leaveClass(user, id);
    }

    @PutMapping("/{id}/status")
    public Map<String, Object> updateStatus(HttpServletRequest request,
                                            @PathVariable UUID id,
                                            @RequestBody Map<String, Object> body) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        String status = (String) body.get("status");
        String recordingUrl = (String) body.get("recordingUrl");
        return liveClassService.updateLiveClassStatus(teacher, id, status, recordingUrl);
    }

    @GetMapping("/{id}/attendance")
    public Map<String, Object> getAttendance(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity teacher = accessService.require(request, "teacher", "admin");
        return liveClassService.getAttendanceReport(teacher, id);
    }
}
