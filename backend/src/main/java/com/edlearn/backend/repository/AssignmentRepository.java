package com.edlearn.backend.repository;

import com.edlearn.backend.model.AssignmentEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AssignmentRepository extends JpaRepository<AssignmentEntity, UUID> {

    List<AssignmentEntity> findByClassroomIdOrderByCreatedAtDesc(UUID classroomId);

    List<AssignmentEntity> findByClassroomIdAndStatusOrderByDueDateAsc(UUID classroomId, String status);

    List<AssignmentEntity> findByClassroomIdAndTopicOrderByCreatedAtDesc(UUID classroomId, String topic);

    List<AssignmentEntity> findByClassroomIdInOrderByDueDateAsc(List<UUID> classroomIds);

    List<AssignmentEntity> findByInstructorIdOrderByCreatedAtDesc(UUID instructorId);

    List<AssignmentEntity> findByCourseIdOrderByCreatedAtDesc(UUID courseId);

    List<AssignmentEntity> findByBatchIdOrderByCreatedAtDesc(UUID batchId);

    @Query("SELECT a FROM AssignmentEntity a WHERE a.batch.id IN :batchIds AND a.status = 'PUBLISHED' ORDER BY a.dueDate ASC NULLS LAST")
    List<AssignmentEntity> findPublishedByBatchIdIn(@Param("batchIds") List<UUID> batchIds);

    @Query("SELECT a FROM AssignmentEntity a WHERE a.course.id IN :courseIds AND a.status = 'PUBLISHED' ORDER BY a.dueDate ASC NULLS LAST")
    List<AssignmentEntity> findPublishedByCourseIdIn(@Param("courseIds") List<UUID> courseIds);

    long countByInstructorId(UUID instructorId);
}
