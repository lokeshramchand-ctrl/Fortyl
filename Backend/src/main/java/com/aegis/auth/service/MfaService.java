package com.aegis.auth.service;

import com.aegis.auth.dto.MfaEnrollResponse;
import com.aegis.auth.entity.MfaSecret;
import com.aegis.auth.entity.MfaSecret.Status;
import com.aegis.auth.repository.MFASecretRepository;
import com.aegis.auth.util.QrCodeUtil;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.Base64;

@Service
public class MfaService {

  private final MFASecretRepository repo;

  public MfaService(MFASecretRepository repo) {
    this.repo = repo;
  }

  public MfaEnrollResponse enroll(String userId) {

    String secret = generateSecret();

    String otpauth = String.format(
        "otpauth://totp/Aegis:%s?secret=%s&issuer=Aegis",
        userId, secret
    );

    MfaSecret entity = new MfaSecret();
    entity.setUserId(userId);
    entity.setEncryptedSecret(secret); // encrypt later
    entity.setStatus(Status.PENDING);

    repo.save(entity);

    String qrBase64 = QrCodeUtil.toBase64Png(otpauth);

    return new MfaEnrollResponse(qrBase64);
  }

  private String generateSecret() {
    byte[] buffer = new byte[20];
    new SecureRandom().nextBytes(buffer);
    return Base64.getEncoder().encodeToString(buffer);
  }
}
