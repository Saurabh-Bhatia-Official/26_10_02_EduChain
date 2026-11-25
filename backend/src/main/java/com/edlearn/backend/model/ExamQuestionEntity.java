package com.edlearn.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "exam_question_bank")
public class ExamQuestionEntity {
    @Id @GeneratedValue
    private UUID id;

    @Column(name = "institute_code", nullable = false, length = 50)
    private String instituteCode;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", nullable = false)
    private UserEntity createdBy;
    @Column(name = "question_text", nullable = false, columnDefinition = "TEXT")
    private String questionText;
    @Column(name = "question_type", nullable = false, length = 40)
    private String questionType;
    @Column(length = 150)
    private String subject;
    @Column(name = "class_name", length = 150)
    private String className;
    @Column(length = 150)
    private String chapter;
    @Column(length = 150)
    private String topic;
    @Column(length = 30)
    private String difficulty = "MEDIUM";
    @Column(nullable = false)
    private int marks;
    @Column(name = "negative_marks", nullable = false)
    private double negativeMarks;
    @Column(name = "options_json", columnDefinition = "TEXT")
    private String optionsJson;
    @Column(name = "correct_answer", columnDefinition = "TEXT")
    private String correctAnswer;
    @Column(columnDefinition = "TEXT")
    private String explanation;
    @Column(nullable = false)
    private int version = 1;
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt = LocalDateTime.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getInstituteCode() { return instituteCode; }
    public void setInstituteCode(String instituteCode) { this.instituteCode = instituteCode; }
    public UserEntity getCreatedBy() { return createdBy; }
    public void setCreatedBy(UserEntity createdBy) { this.createdBy = createdBy; }
    public String getQuestionText() { return questionText; }
    public void setQuestionText(String questionText) { this.questionText = questionText; }
    public String getQuestionType() { return questionType; }
    public void setQuestionType(String questionType) { this.questionType = questionType; }
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }
    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }
    public String getChapter() { return chapter; }
    public void setChapter(String chapter) { this.chapter = chapter; }
    public String getTopic() { return topic; }
    public void setTopic(String topic) { this.topic = topic; }
    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }
    public int getMarks() { return marks; }
    public void setMarks(int marks) { this.marks = marks; }
    public double getNegativeMarks() { return negativeMarks; }
    public void setNegativeMarks(double negativeMarks) { this.negativeMarks = negativeMarks; }
    public String getOptionsJson() { return optionsJson; }
    public void setOptionsJson(String optionsJson) { this.optionsJson = optionsJson; }
    public String getCorrectAnswer() { return correctAnswer; }
    public void setCorrectAnswer(String correctAnswer) { this.correctAnswer = correctAnswer; }
    public String getExplanation() { return explanation; }
    public void setExplanation(String explanation) { this.explanation = explanation; }
    public int getVersion() { return version; }
    public void setVersion(int version) { this.version = version; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
