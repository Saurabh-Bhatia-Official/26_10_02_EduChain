package com.edlearn.backend.controller;

import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.service.ClassroomService;
import com.edlearn.backend.service.CommentService;
import com.edlearn.backend.service.PortalAccessService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/classrooms")
@CrossOrigin(originPatterns = "*", allowedHeaders = "*")
public class ClassroomController {

    private final ClassroomService classroomService;
    private final CommentService commentService;
    private final PortalAccessService accessService;

    public ClassroomController(ClassroomService classroomService,
                               CommentService commentService,
                               PortalAccessService accessService) {
        this.classroomService = classroomService;
        this.commentService = commentService;
        this.accessService = accessService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> createClassroom(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        UserEntity user = accessService.require(request, "teacher", "admin");
        return classroomService.createClassroom(user, body);
    }

    @GetMapping
    public List<Map<String, Object>> getUserClassrooms(HttpServletRequest request) {
        UserEntity user = accessService.require(request, "teacher", "student", "admin");
        return classroomService.getUserClassrooms(user);
    }

    @GetMapping("/{id}")
    public Map<String, Object> getClassroomDetails(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity user = accessService.require(request, "teacher", "student", "admin");
        return classroomService.getClassroomDetails(user, id);
    }

    @PutMapping("/{id}")
    public Map<String, Object> updateClassroom(HttpServletRequest request, @PathVariable UUID id, @RequestBody Map<String, Object> body) {
        UserEntity user = accessService.require(request, "teacher", "admin");
        return classroomService.updateClassroom(user, id, body);
    }

    @PostMapping("/join")
    public Map<String, Object> joinByCode(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        UserEntity user = accessService.require(request, "student", "teacher", "admin");
        String code = (String) body.get("code");
        return classroomService.joinByInvitationCode(user, code);
    }

    @GetMapping("/{id}/members")
    public Map<String, Object> getMembers(HttpServletRequest request, @PathVariable UUID id) {
        UserEntity user = accessService.require(request, "teacher", "student", "admin");
        return classroomService.getMembers(user, id);
    }

    @PostMapping("/{id}/members/{userId}/status")
    public Map<String, Object> updateMemberStatus(HttpServletRequest request,
                                                  @PathVariable UUID id,
                                                  @PathVariable UUID userId,
                                                  @RequestBody Map<String, Object> body) {
        UserEntity user = accessService.require(request, "teacher", "admin");
        String status = (String) body.get("status");
        return classroomService.updateMemberStatus(user, id, userId, status);
    }

    @PutMapping("/{id}/archive")
    public Map<String, Object> archiveClassroom(HttpServletRequest request,
                                                @PathVariable UUID id,
                                                @RequestBody Map<String, Object> body) {
        UserEntity user = accessService.require(request, "teacher", "admin");
        boolean archive = Boolean.TRUE.equals(body.get("archive"));
        return classroomService.archiveClassroom(user, id, archive);
    }

    @GetMapping("/{id}/comments")
    public List<Map<String, Object>> getComments(HttpServletRequest request,
                                                 @PathVariable UUID id,
                                                 @RequestParam(defaultValue = "STREAM_POST") String targetType,
                                                 @RequestParam(required = false) UUID targetId) {
        UserEntity user = accessService.require(request, "teacher", "student", "admin");
        classroomService.requireClassroomAccess(user, id);
        return commentService.getComments(id, targetType, targetId);
    }

    @PostMapping("/{id}/comments")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> addComment(HttpServletRequest request,
                                          @PathVariable UUID id,
                                          @RequestBody Map<String, Object> body) {
        UserEntity user = accessService.require(request, "teacher", "student", "admin");
        return commentService.addComment(user, id, body);
    }

    @DeleteMapping("/comments/{commentId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteComment(HttpServletRequest request, @PathVariable UUID commentId) {
        UserEntity user = accessService.require(request, "teacher", "student", "admin");
        commentService.deleteComment(user, commentId);
    }
}
