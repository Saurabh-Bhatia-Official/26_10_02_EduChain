package com.edlearn.backend.repository;

import com.edlearn.backend.model.AssignmentAttachmentEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AssignmentAttachmentRepository extends JpaRepository<AssignmentAttachmentEntity, UUID> {

    List<AssignmentAttachmentEntity> findByAssignmentIdOrderByUploadedAtAsc(UUID assignmentId);

    List<AssignmentAttachmentEntity> findBySubmissionIdOrderByUploadedAtAsc(UUID submissionId);
}
