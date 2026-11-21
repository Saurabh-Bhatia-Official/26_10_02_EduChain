package com.edlearn.backend.repository;

import com.edlearn.backend.model.AssignmentEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AssignmentRepository extends JpaRepository<AssignmentEntity, UUID> {

    List<AssignmentEntity> findByClassroomIdOrderByCreatedAtDesc(UUID classroomId);

    List<AssignmentEntity> findByClassroomIdAndStatusOrderByDueDateAsc(UUID classroomId, String status);

    List<AssignmentEntity> findByClassroomIdAndTopicOrderByCreatedAtDesc(UUID classroomId, String topic);

    List<AssignmentEntity> findByClassroomIdInOrderByDueDateAsc(List<UUID> classroomIds);
}
