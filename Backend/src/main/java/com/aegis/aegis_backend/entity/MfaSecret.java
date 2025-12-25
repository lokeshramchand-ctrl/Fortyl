package com.aegis.aegis_backend.entity;

import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "mfa_secrets")
public class MfaSecret {
    @Id
    @GeneratedValue
    private UUID id;

    private String userId;

    @Column(nullable = false)
    private String encryptedString;

    @Enumerated(EnumType.STRING)
    private Status status;

    public enum Status {
        ACTIVE,
        PENDING,
        REVOKED,
    }

}
