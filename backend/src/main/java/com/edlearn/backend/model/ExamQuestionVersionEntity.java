package com.edlearn.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "exam_question_versions", uniqueConstraints = @UniqueConstraint(columnNames = {"question_id", "version_number"}))
public class ExamQuestionVersionEntity {
    @Id @GeneratedValue
    private UUID id;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private ExamQuestionEntity question;
    @Column(name = "version_number", nullable = false)
    private int versionNumber;
    @Column(name = "question_snapshot", nullable = false, columnDefinition = "TEXT")
    private String questionSnapshot;
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public ExamQuestionEntity getQuestion() { return question; }
    public void setQuestion(ExamQuestionEntity question) { this.question = question; }
    public int getVersionNumber() { return versionNumber; }
    public void setVersionNumber(int versionNumber) { this.versionNumber = versionNumber; }
    public String getQuestionSnapshot() { return questionSnapshot; }
    public void setQuestionSnapshot(String questionSnapshot) { this.questionSnapshot = questionSnapshot; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
