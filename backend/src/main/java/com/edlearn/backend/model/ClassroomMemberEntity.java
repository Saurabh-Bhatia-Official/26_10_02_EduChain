package com.edlearn.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "classroom_members", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"classroom_id", "user_id"})
})
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class ClassroomMemberEntity {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "classroom_id", nullable = false)
    private ClassroomEntity classroom;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(nullable = false, length = 30)
    private String role; // TEACHER, STUDENT, CO_TEACHER

    @Column(length = 30)
    private String status = "ACTIVE"; // ACTIVE, PENDING_APPROVAL, REJECTED

    @Column(name = "enrolled_at")
    private LocalDateTime enrolledAt = LocalDateTime.now();

    public ClassroomMemberEntity() {}

    public ClassroomMemberEntity(ClassroomEntity classroom, UserEntity user, String role, String status) {
        this.classroom = classroom;
        this.user = user;
        this.role = role;
        this.status = status;
        this.enrolledAt = LocalDateTime.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public ClassroomEntity getClassroom() { return classroom; }
    public void setClassroom(ClassroomEntity classroom) { this.classroom = classroom; }

    public UserEntity getUser() { return user; }
    public void setUser(UserEntity user) { this.user = user; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getEnrolledAt() { return enrolledAt; }
    public void setEnrolledAt(LocalDateTime enrolledAt) { this.enrolledAt = enrolledAt; }
}
