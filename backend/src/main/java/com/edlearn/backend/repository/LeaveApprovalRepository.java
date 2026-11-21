package com.edlearn.backend.repository;

import com.edlearn.backend.model.LeaveApprovalEntity;
import com.edlearn.backend.model.LeaveApplicationEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface LeaveApprovalRepository extends JpaRepository<LeaveApprovalEntity, Long> {
    List<LeaveApprovalEntity> findByApplicationOrderByReviewedAtAsc(LeaveApplicationEntity application);
}
