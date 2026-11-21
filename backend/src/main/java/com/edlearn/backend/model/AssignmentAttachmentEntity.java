package com.edlearn.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "assignment_attachments")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class AssignmentAttachmentEntity {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assignment_id")
    private AssignmentEntity assignment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "submission_id")
    private AssignmentSubmissionEntity submission;

    @Column(name = "file_name", nullable = false)
    private String fileName;

    @Column(name = "file_url", nullable = false, length = 1000)
    private String fileUrl;

    @Column(name = "file_type", length = 100)
    private String fileType;

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "cloudinary_public_id")
    private String cloudinaryPublicId;

    @Column(name = "uploaded_at")
    private LocalDateTime uploadedAt = LocalDateTime.now();

    public AssignmentAttachmentEntity() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public AssignmentEntity getAssignment() { return assignment; }
    public void setAssignment(AssignmentEntity assignment) { this.assignment = assignment; }

    public AssignmentSubmissionEntity getSubmission() { return submission; }
    public void setSubmission(AssignmentSubmissionEntity submission) { this.submission = submission; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }

    public String getFileType() { return fileType; }
    public void setFileType(String fileType) { this.fileType = fileType; }

    public Long getFileSize() { return fileSize; }
    public void setFileSize(Long fileSize) { this.fileSize = fileSize; }

    public String getCloudinaryPublicId() { return cloudinaryPublicId; }
    public void setCloudinaryPublicId(String cloudinaryPublicId) { this.cloudinaryPublicId = cloudinaryPublicId; }

    public LocalDateTime getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(LocalDateTime uploadedAt) { this.uploadedAt = uploadedAt; }
}
