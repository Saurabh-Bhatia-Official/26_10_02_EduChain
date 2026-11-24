package com.edlearn.backend.service;

import com.edlearn.backend.model.ClassroomEntity;
import com.edlearn.backend.model.CommentEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.ClassroomMemberRepository;
import com.edlearn.backend.repository.ClassroomRepository;
import com.edlearn.backend.repository.CommentRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class CommentService {

    private final CommentRepository commentRepository;
    private final ClassroomRepository classroomRepository;
    private final ClassroomMemberRepository memberRepository;

    public CommentService(CommentRepository commentRepository,
                          ClassroomRepository classroomRepository,
                          ClassroomMemberRepository memberRepository) {
        this.commentRepository = commentRepository;
        this.classroomRepository = classroomRepository;
        this.memberRepository = memberRepository;
    }

    @Transactional
    public Map<String, Object> addComment(UserEntity author, UUID classroomId, Map<String, Object> body) {
        ClassroomEntity classroom = classroomRepository.findById(classroomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Classroom not found."));

        boolean isMember = memberRepository.existsByClassroomIdAndUserIdAndStatus(classroomId, author.getId(), "ACTIVE");
        boolean isAdmin = "admin".equalsIgnoreCase(author.getRole())
                && author.getInstituteCode() != null && author.getInstituteCode().equalsIgnoreCase(classroom.getInstituteCode());

        if (!isMember && !isAdmin) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You must be enrolled to post in this classroom.");
        }

        String content = (String) body.get("content");
        if (content == null || content.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Comment content cannot be empty.");
        }

        CommentEntity comment = new CommentEntity();
        comment.setClassroom(classroom);
        comment.setAuthor(author);
        comment.setContent(content.trim());

        String targetType = (String) body.getOrDefault("targetType", "STREAM_POST");
        if (!Set.of("STREAM_POST", "ANNOUNCEMENT", "ASSIGNMENT", "SUBMISSION", "COMMENT").contains(targetType)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported comment target type.");
        }
        comment.setTargetType(targetType);

        if (body.get("targetId") != null) {
            comment.setTargetId(parseId(body.get("targetId"), "Invalid target id."));
        }

        if (body.get("parentId") != null) {
            UUID parentId = parseId(body.get("parentId"), "Invalid parent comment id.");
            CommentEntity parent = commentRepository.findById(parentId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Parent comment not found."));
            if (!parent.getClassroom().getId().equals(classroomId)
                    || !Objects.equals(parent.getTargetId(), comment.getTargetId())
                    || !Objects.equals(parent.getTargetType(), comment.getTargetType())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Parent comment must belong to the same classroom thread.");
            }
            comment.setParent(parent);
        }

        comment.setCreatedAt(LocalDateTime.now());
        CommentEntity saved = commentRepository.save(comment);

        return formatComment(saved);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getComments(UUID classroomId, String targetType, UUID targetId) {
        if (!Set.of("STREAM_POST", "ANNOUNCEMENT", "ASSIGNMENT", "SUBMISSION", "COMMENT").contains(targetType)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported comment target type.");
        }
        List<CommentEntity> list;
        if (targetId != null) {
            list = commentRepository.findByClassroomIdAndTargetTypeAndTargetIdOrderByCreatedAtAsc(classroomId, targetType, targetId);
        } else {
            list = commentRepository.findByClassroomIdAndTargetTypeOrderByCreatedAtDesc(classroomId, targetType);
        }
        return list.stream().map(this::formatComment).collect(Collectors.toList());
    }

    @Transactional
    public void deleteComment(UserEntity user, UUID commentId) {
        CommentEntity comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Comment not found."));

        boolean isAuthor = comment.getAuthor().getId().equals(user.getId());
        boolean sameInstitute = user.getInstituteCode() != null && comment.getClassroom().getInstituteCode() != null
                && user.getInstituteCode().equalsIgnoreCase(comment.getClassroom().getInstituteCode());
        boolean isAdmin = "admin".equalsIgnoreCase(user.getRole()) && sameInstitute;
        boolean isTeacher = memberRepository.findByClassroomIdAndUserId(comment.getClassroom().getId(), user.getId())
                .map(m -> "ACTIVE".equalsIgnoreCase(m.getStatus())
                        && ("TEACHER".equalsIgnoreCase(m.getRole()) || "CO_TEACHER".equalsIgnoreCase(m.getRole())))
                .orElse(false);

        if (!sameInstitute || (!isAuthor && !isAdmin && !isTeacher)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have permission to delete this comment.");
        }

        commentRepository.delete(comment);
    }

    private Map<String, Object> formatComment(CommentEntity c) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", c.getId());
        map.put("classroomId", c.getClassroom().getId());
        map.put("authorId", c.getAuthor().getId());
        map.put("authorName", c.getAuthor().getName());
        map.put("authorRole", c.getAuthor().getRole());
        map.put("authorAvatarUrl", c.getAuthor().getAvatarUrl());
        map.put("content", c.getContent());
        map.put("targetType", c.getTargetType());
        map.put("targetId", c.getTargetId());
        map.put("parentId", c.getParent() != null ? c.getParent().getId() : null);
        map.put("createdAt", c.getCreatedAt().toString());
        return map;
    }

    private UUID parseId(Object value, String message) {
        try { return UUID.fromString(Objects.toString(value)); }
        catch (IllegalArgumentException ex) { throw new ResponseStatusException(HttpStatus.BAD_REQUEST, message); }
    }
}
