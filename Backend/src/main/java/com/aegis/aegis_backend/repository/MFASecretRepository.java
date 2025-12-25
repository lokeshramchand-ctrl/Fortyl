package com.aegis.aegis_backend.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.aegis.aegis_backend.entity.MfaSecret;
import com.aegis.aegis_backend.entity.MfaSecret.Status;

public interface MFASecretRepository extends JpaRepository<MfaSecret, UUID> {
    Optional<MfaSecret> findByUserIdAndStatus(String userId, Status status);

    
}