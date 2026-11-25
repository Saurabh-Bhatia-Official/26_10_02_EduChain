package com.edlearn.backend.repository;

import com.edlearn.backend.model.UserOAuthTokenEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserOAuthTokenRepository extends JpaRepository<UserOAuthTokenEntity, UUID> {

    Optional<UserOAuthTokenEntity> findByUserIdAndProvider(UUID userId, String provider);

    Optional<UserOAuthTokenEntity> findByUserId(UUID userId);
}
