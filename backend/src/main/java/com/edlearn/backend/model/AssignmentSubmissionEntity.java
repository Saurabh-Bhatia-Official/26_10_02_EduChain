package com.edlearn.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "assignment_submissions", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"assignment_id", "student_id"})
})
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class AssignmentSubmissionEntity {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "assignment_id", nullable = false)
    private AssignmentEntity assignment;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "student_id", nullable = false)
    private UserEntity student;

    @Column(name = "submission_text", columnDefinition = "TEXT")
    private String submissionText;

    @Column(length = 30)
    private String status = "TURNED_IN"; // ASSIGNED, TURNED_IN, GRADED, RETURNED, LATE

    @Column(name = "version_number")
    private int versionNumber = 1;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt = LocalDateTime.now();

    public AssignmentSubmissionEntity() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public AssignmentEntity getAssignment() { return assignment; }
    public void setAssignment(AssignmentEntity assignment) { this.assignment = assignment; }

    public UserEntity getStudent() { return student; }
    public void setStudent(UserEntity student) { this.student = student; }

    public String getSubmissionText() { return submissionText; }
    public void setSubmissionText(String submissionText) { this.submissionText = submissionText; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getVersionNumber() { return versionNumber; }
    public void setVersionNumber(int versionNumber) { this.versionNumber = versionNumber; }

    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }
}
