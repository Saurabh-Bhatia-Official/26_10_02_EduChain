package com.edlearn.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "student_profiles", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"user_id"})
})
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class StudentProfileEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(name = "student_id")
    private String studentId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "batch_id")
    private BatchEntity batch;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public StudentProfileEntity() {}

    public StudentProfileEntity(UserEntity user, String studentId, BatchEntity batch) {
        this.user = user;
        this.studentId = studentId;
        this.batch = batch;
        this.createdAt = LocalDateTime.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UserEntity getUser() { return user; }
    public void setUser(UserEntity user) { this.user = user; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public BatchEntity getBatch() { return batch; }
    public void setBatch(BatchEntity batch) { this.batch = batch; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
