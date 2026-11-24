package com.edlearn.backend.repository;

import com.edlearn.backend.model.LeaveApplicationEntity;
import com.edlearn.backend.model.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface LeaveApplicationRepository extends JpaRepository<LeaveApplicationEntity, UUID> {
    List<LeaveApplicationEntity> findByApplicantOrderByCreatedAtDesc(UserEntity applicant);
    List<LeaveApplicationEntity> findByAssignedTeacherOrderByCreatedAtDesc(UserEntity assignedTeacher);
    boolean existsByApplicantAndStartDateAndEndDateAndLeaveTypeIgnoreCase(
            UserEntity applicant, LocalDate startDate, LocalDate endDate, String leaveType);
}
