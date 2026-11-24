package com.edlearn.backend.repository;

import com.edlearn.backend.model.AssignmentSubmissionEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AssignmentSubmissionRepository extends JpaRepository<AssignmentSubmissionEntity, UUID> {

    Optional<AssignmentSubmissionEntity> findByAssignmentIdAndStudentId(UUID assignmentId, UUID studentId);

    List<AssignmentSubmissionEntity> findByAssignmentIdOrderBySubmittedAtAsc(UUID assignmentId);

    List<AssignmentSubmissionEntity> findByStudentIdOrderBySubmittedAtDesc(UUID studentId);

    List<AssignmentSubmissionEntity> findByAssignmentIdIn(List<UUID> assignmentIds);

    long countByAssignmentIdAndStatus(UUID assignmentId, String status);

    long countByStudentId(UUID studentId);
}
