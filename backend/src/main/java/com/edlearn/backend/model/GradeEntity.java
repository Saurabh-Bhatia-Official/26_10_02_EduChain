package com.edlearn.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "grades", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"submission_id"})
})
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class GradeEntity {

    @Id
    @GeneratedValue
    private UUID id;

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "submission_id", nullable = false)
    private AssignmentSubmissionEntity submission;

    @Column(nullable = false, precision = 6, scale = 2)
    private BigDecimal score;

    @Column(columnDefinition = "TEXT")
    private String feedback;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "graded_by", nullable = false)
    private UserEntity gradedBy;

    @Column(name = "graded_at")
    private LocalDateTime gradedAt = LocalDateTime.now();

    @Column(name = "is_returned")
    private boolean isReturned = false;

    public GradeEntity() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public AssignmentSubmissionEntity getSubmission() { return submission; }
    public void setSubmission(AssignmentSubmissionEntity submission) { this.submission = submission; }

    public BigDecimal getScore() { return score; }
    public void setScore(BigDecimal score) { this.score = score; }

    public String getFeedback() { return feedback; }
    public void setFeedback(String feedback) { this.feedback = feedback; }

    public UserEntity getGradedBy() { return gradedBy; }
    public void setGradedBy(UserEntity gradedBy) { this.gradedBy = gradedBy; }

    public LocalDateTime getGradedAt() { return gradedAt; }
    public void setGradedAt(LocalDateTime gradedAt) { this.gradedAt = gradedAt; }

    public boolean isReturned() { return isReturned; }
    public void setReturned(boolean returned) { isReturned = returned; }
}
