package com.edlearn.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "assignments")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class AssignmentEntity {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "classroom_id", nullable = false)
    private ClassroomEntity classroom;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String instructions;

    @Column(name = "points_possible")
    private int pointsPossible = 100;

    @Column(name = "due_date")
    private LocalDateTime dueDate;

    @Column(length = 100)
    private String topic = "General";

    @Column(name = "allow_late_submissions")
    private boolean allowLateSubmissions = true;

    @Column(length = 30)
    private String status = "PUBLISHED"; // DRAFT, PUBLISHED, SCHEDULED

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "created_by", nullable = false)
    private UserEntity createdBy;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    public AssignmentEntity() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public ClassroomEntity getClassroom() { return classroom; }
    public void setClassroom(ClassroomEntity classroom) { this.classroom = classroom; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getInstructions() { return instructions; }
    public void setInstructions(String instructions) { this.instructions = instructions; }

    public int getPointsPossible() { return pointsPossible; }
    public void setPointsPossible(int pointsPossible) { this.pointsPossible = pointsPossible; }

    public LocalDateTime getDueDate() { return dueDate; }
    public void setDueDate(LocalDateTime dueDate) { this.dueDate = dueDate; }

    public String getTopic() { return topic; }
    public void setTopic(String topic) { this.topic = topic; }

    public boolean isAllowLateSubmissions() { return allowLateSubmissions; }
    public void setAllowLateSubmissions(boolean allowLateSubmissions) { this.allowLateSubmissions = allowLateSubmissions; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public UserEntity getCreatedBy() { return createdBy; }
    public void setCreatedBy(UserEntity createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
