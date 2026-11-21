package com.edlearn.backend.controller;

import com.edlearn.backend.dto.PortalRequests.AnnouncementRequest;
import com.edlearn.backend.dto.PortalRequests.DecisionRequest;
import com.edlearn.backend.dto.PortalRequests.LeaveRequest;
import com.edlearn.backend.dto.PortalRequests.TeacherAssignmentRequest;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.service.PortalAccessService;
import com.edlearn.backend.service.PortalModuleService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/portal")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class PortalModuleController {
    private final PortalAccessService accessService;
    private final PortalModuleService moduleService;

    public PortalModuleController(PortalAccessService accessService, PortalModuleService moduleService) {
        this.accessService = accessService;
        this.moduleService = moduleService;
    }

    @GetMapping("/announcements")
    public List<Map<String, Object>> announcements(HttpServletRequest request) {
        return moduleService.announcements(accessService.require(request, "admin", "teacher", "student"));
    }

    @PostMapping("/announcements")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> createAnnouncement(HttpServletRequest request,
                                                   @Valid @RequestBody AnnouncementRequest body) {
        return moduleService.createAnnouncement(accessService.require(request, "admin"), body);
    }

    @PutMapping("/announcements/{id}")
    public Map<String, Object> updateAnnouncement(HttpServletRequest request, @PathVariable UUID id,
                                                   @Valid @RequestBody AnnouncementRequest body) {
        return moduleService.updateAnnouncement(accessService.require(request, "admin"), id, body);
    }

    @DeleteMapping("/announcements/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteAnnouncement(HttpServletRequest request, @PathVariable UUID id) {
        moduleService.deleteAnnouncement(accessService.require(request, "admin"), id);
    }

    @PostMapping("/announcements/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markAnnouncementRead(HttpServletRequest request, @PathVariable UUID id) {
        moduleService.markAnnouncementRead(accessService.require(request, "teacher", "student"), id);
    }

    @GetMapping("/leaves")
    public List<Map<String, Object>> leaves(HttpServletRequest request,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String applicantRole,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) String search) {
        return moduleService.leaves(accessService.require(request, "admin", "teacher", "student"),
                status, applicantRole, from, to, search);
    }

    @PostMapping("/leaves")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> createLeave(HttpServletRequest request, @Valid @RequestBody LeaveRequest body) {
        return moduleService.submitLeave(accessService.require(request, "teacher", "student"), body);
    }

    @PostMapping("/leaves/{id}/decision")
    public Map<String, Object> decideLeave(HttpServletRequest request, @PathVariable UUID id,
                                            @Valid @RequestBody DecisionRequest body) {
        return moduleService.decideLeave(accessService.require(request, "admin", "teacher"), id, body);
    }

    @GetMapping("/notifications")
    public List<Map<String, Object>> notifications(HttpServletRequest request) {
        return moduleService.notifications(accessService.require(request, "admin", "teacher", "student"));
    }

    @GetMapping("/notifications/unread-count")
    public Map<String, Long> unreadNotificationCount(HttpServletRequest request) {
        return Map.of("count", moduleService.unreadNotificationCount(accessService.require(request, "admin", "teacher", "student")));
    }

    @PostMapping("/notifications/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markNotificationRead(HttpServletRequest request, @PathVariable UUID id) {
        moduleService.markNotificationRead(accessService.require(request, "admin", "teacher", "student"), id);
    }

    @GetMapping("/admin/assignment-options")
    public Map<String, Object> assignmentOptions(HttpServletRequest request) {
        return moduleService.assignmentOptions(accessService.require(request, "admin"));
    }

    @PutMapping("/admin/students/{studentId}/teacher")
    public Map<String, Object> assignTeacher(HttpServletRequest request, @PathVariable UUID studentId,
                                             @Valid @RequestBody TeacherAssignmentRequest body) {
        UUID teacherId;
        try {
            teacherId = UUID.fromString(body.teacherId());
        } catch (IllegalArgumentException ex) {
            throw new org.springframework.web.server.ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid teacher ID.");
        }
        return moduleService.assignTeacher(accessService.require(request, "admin"), studentId, teacherId);
    }
}
