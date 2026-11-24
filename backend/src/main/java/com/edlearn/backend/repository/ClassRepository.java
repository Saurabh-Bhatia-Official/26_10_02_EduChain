package com.edlearn.backend.repository;

import com.edlearn.backend.model.ClassEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ClassRepository extends JpaRepository<ClassEntity, UUID> {
    List<ClassEntity> findByInstructorIdOrderByCreatedAtDesc(UUID instructorId);
    List<ClassEntity> findByCourseIdOrderByCreatedAtDesc(UUID courseId);
    List<ClassEntity> findByBatchIdOrderByCreatedAtDesc(UUID batchId);

    @Query("SELECT c FROM ClassEntity c WHERE c.batch.id IN :batchIds ORDER BY c.classDate ASC, c.startTime ASC")
    List<ClassEntity> findByBatchIdIn(@Param("batchIds") List<UUID> batchIds);

    @Query("SELECT c FROM ClassEntity c WHERE c.course.id IN :courseIds ORDER BY c.classDate ASC, c.startTime ASC")
    List<ClassEntity> findByCourseIdIn(@Param("courseIds") List<UUID> courseIds);

    long countByInstructorId(UUID instructorId);
    long countByInstructorIdAndStatusIgnoreCase(UUID instructorId, String status);
    long countByStatusIgnoreCase(String status);
}
