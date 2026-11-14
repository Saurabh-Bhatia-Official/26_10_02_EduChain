package com.edlearn.backend.repository;

import com.edlearn.backend.model.InstituteEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface InstituteRepository extends JpaRepository<InstituteEntity, UUID> {
    Optional<InstituteEntity> findByInstituteCodeIgnoreCase(String instituteCode);
    Optional<InstituteEntity> findByEmailIgnoreCase(String email);
    Optional<InstituteEntity> findByEmailIgnoreCaseAndInstituteCodeIgnoreCase(String email, String instituteCode);
    boolean existsByInstituteCodeIgnoreCase(String instituteCode);
    boolean existsByEmailIgnoreCase(String email);
}
