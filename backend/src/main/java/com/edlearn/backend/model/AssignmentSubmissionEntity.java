package com.edlearn.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.math.BigDecimal;
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

    @Column(name = "submission_file_url", length = 1000)
    private String submissionFileUrl;

    @Column(name = "student_comments", columnDefinition = "TEXT")
    private String studentComments;

    @Column(length = 30)
    private String status = "Submitted"; // New, Pending, Submitted, Under Review, Evaluated, Late, ASSIGNED, TURNED_IN, GRADED, RETURNED

    @Column(name = "marks_obtained", precision = 6, scale = 2)
    private BigDecimal marksObtained;

    @Column(name = "instructor_feedback", columnDefinition = "TEXT")
    private String instructorFeedback;

    @Column(name = "evaluated_file_url", length = 1000)
    private String evaluatedFileUrl;

    @Column(name = "evaluated_at")
    private LocalDateTime evaluatedAt;

    @Column(name = "version_number")
    private int versionNumber = 1;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    public AssignmentSubmissionEntity() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public AssignmentEntity getAssignment() { return assignment; }
    public void setAssignment(AssignmentEntity assignment) { this.assignment = assignment; }

    public UserEntity getStudent() { return student; }
    public void setStudent(UserEntity student) { this.student = student; }

    public String getSubmissionText() { return submissionText; }
    public void setSubmissionText(String submissionText) { this.submissionText = submissionText; }

    public String getSubmissionFileUrl() { return submissionFileUrl; }
    public void setSubmissionFileUrl(String submissionFileUrl) { this.submissionFileUrl = submissionFileUrl; }

    public String getStudentComments() { return studentComments; }
    public void setStudentComments(String studentComments) { this.studentComments = studentComments; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public BigDecimal getMarksObtained() { return marksObtained; }
    public void setMarksObtained(BigDecimal marksObtained) { this.marksObtained = marksObtained; }

    public String getInstructorFeedback() { return instructorFeedback; }
    public void setInstructorFeedback(String instructorFeedback) { this.instructorFeedback = instructorFeedback; }

    public String getEvaluatedFileUrl() { return evaluatedFileUrl; }
    public void setEvaluatedFileUrl(String evaluatedFileUrl) { this.evaluatedFileUrl = evaluatedFileUrl; }

    public LocalDateTime getEvaluatedAt() { return evaluatedAt; }
    public void setEvaluatedAt(LocalDateTime evaluatedAt) { this.evaluatedAt = evaluatedAt; }

    public int getVersionNumber() { return versionNumber; }
    public void setVersionNumber(int versionNumber) { this.versionNumber = versionNumber; }

    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
