package com.edlearn.backend.repository;

import com.edlearn.backend.model.CommentEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CommentRepository extends JpaRepository<CommentEntity, UUID> {

    List<CommentEntity> findByClassroomIdAndTargetTypeAndTargetIdOrderByCreatedAtAsc(UUID classroomId, String targetType, UUID targetId);

    List<CommentEntity> findByClassroomIdAndTargetTypeOrderByCreatedAtDesc(UUID classroomId, String targetType);

    List<CommentEntity> findByParentIdOrderByCreatedAtAsc(UUID parentId);
}
