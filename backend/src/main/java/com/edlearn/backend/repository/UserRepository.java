package com.edlearn.backend.repository;

import com.edlearn.backend.model.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<UserEntity, UUID> {
    Optional<UserEntity> findByEmailIgnoreCase(String email);
    Optional<UserEntity> findByEmailIgnoreCaseAndRoleIgnoreCase(String email, String role);
    Optional<UserEntity> findByEmailIgnoreCaseAndRoleIgnoreCaseAndInstituteCodeIgnoreCase(String email, String role, String instituteCode);
    Optional<UserEntity> findByUserId(String userId);
    Optional<UserEntity> findByRollNumberIgnoreCase(String rollNumber);
    Optional<UserEntity> findByInstructorIdIgnoreCase(String instructorId);
    List<UserEntity> findByRoleIgnoreCase(String role);
    List<UserEntity> findByRoleIgnoreCaseOrderByCreatedAtDesc(String role);
    List<UserEntity> findByInstituteCodeIgnoreCase(String instituteCode);
    List<UserEntity> findByInstituteCodeIgnoreCaseAndRoleIgnoreCase(String instituteCode, String role);
    List<UserEntity> findByInstituteCodeIgnoreCaseAndRoleIgnoreCaseOrderByCreatedAtDesc(String instituteCode, String role);
    long countByRoleIgnoreCase(String role);
    long countByInstituteCodeIgnoreCase(String instituteCode);
    long countByInstituteCodeIgnoreCaseAndRoleIgnoreCase(String instituteCode, String role);
    boolean existsByEmailIgnoreCase(String email);
    boolean existsByRollNumberIgnoreCase(String rollNumber);
    boolean existsByInstructorIdIgnoreCase(String instructorId);
}
