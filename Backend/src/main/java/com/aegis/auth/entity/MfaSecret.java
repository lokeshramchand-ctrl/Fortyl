package com.aegis.auth.entity;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "mfa_secrets")
public class MfaSecret {

  @Id
  @GeneratedValue
  private UUID id;

  @Column(nullable = false)
  private String userId;

  @Column(nullable = false)
  private String encryptedSecret;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Status status;

  public enum Status {
    PENDING,
    ACTIVE,
    REVOKED
  }

  // Getters & Setters
  public UUID getId() { return id; }
  public void setId(UUID id) { this.id = id; }

  public String getUserId() { return userId; }
  public void setUserId(String userId) { this.userId = userId; }

  public String getEncryptedSecret() { return encryptedSecret; }
  public void setEncryptedSecret(String encryptedSecret) {
    this.encryptedSecret = encryptedSecret;
  }

  public Status getStatus() { return status; }
  public void setStatus(Status status) { this.status = status; }
}
