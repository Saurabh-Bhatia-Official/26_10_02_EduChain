package com.edlearn.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "leave_approvals")
public class LeaveApprovalEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "application_id", nullable = false)
    private LeaveApplicationEntity application;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "reviewer_id", nullable = false)
    private UserEntity reviewer;

    @Column(nullable = false, length = 20)
    private String decision;

    @Column(length = 1000)
    private String remark;

    @Column(name = "reviewed_at", nullable = false)
    private LocalDateTime reviewedAt = LocalDateTime.now();

    public LeaveApprovalEntity() {}
    public LeaveApprovalEntity(LeaveApplicationEntity application, UserEntity reviewer, String decision, String remark) {
        this.application = application;
        this.reviewer = reviewer;
        this.decision = decision;
        this.remark = remark;
    }

    public UserEntity getReviewer() { return reviewer; }
    public String getDecision() { return decision; }
    public String getRemark() { return remark; }
    public LocalDateTime getReviewedAt() { return reviewedAt; }
    public LeaveApplicationEntity getApplication() { return application; }
}
