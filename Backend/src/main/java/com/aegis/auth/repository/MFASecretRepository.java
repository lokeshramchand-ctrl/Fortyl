package com.aegis.auth.repository;

import com.aegis.auth.entity.MfaSecret;
import com.aegis.auth.entity.MfaSecret.Status;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface MfaSecretRepository
    extends JpaRepository<MfaSecret, UUID> {

  Optional<MfaSecret> findByUserIdAndStatus(String userId, Status status);
}
