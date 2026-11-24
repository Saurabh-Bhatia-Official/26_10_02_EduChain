package com.edlearn.backend.repository;

import com.edlearn.backend.model.InstructorProfileEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface InstructorProfileRepository extends JpaRepository<InstructorProfileEntity, UUID> {
    Optional<InstructorProfileEntity> findByUserId(UUID userId);
    void deleteByUserId(UUID userId);
}
