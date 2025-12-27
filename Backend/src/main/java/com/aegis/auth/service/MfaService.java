package com.aegis.auth.service;

import com.aegis.auth.dto.MfaEnrollResponse;
import com.aegis.auth.entity.MfaSecret;
import com.aegis.auth.entity.MfaSecret.Status;
import com.aegis.auth.repository.MfaSecretRepository;
import com.aegis.auth.util.QrCodeUtil;
import org.springframework.stereotype.Service;
import org.apache.commons.codec.binary.Base32;
import java.security.SecureRandom;

@Service
public class MfaService {

  private final MfaSecretRepository repo;

  public MfaService(MfaSecretRepository repo) {
    this.repo = repo;
  }

  public MfaEnrollResponse enroll(String userId) {

    String secret = generateSecret();

String otpauth = String.format(
  "otpauth://totp/%s:%s?secret=%s&issuer=%s&digits=6&period=30",
  "Aegis", userId, secret, "Aegis"
);

    MfaSecret entity = new MfaSecret();
    entity.setUserId(userId);
    entity.setEncryptedSecret(secret); // encrypt later
    entity.setStatus(Status.PENDING);

    repo.save(entity);

    String qrBase64 = QrCodeUtil.toBase64Png(otpauth);

    return new MfaEnrollResponse(qrBase64);
  }

public String generateSecret() {
    byte[] buffer = new byte[20]; // 160 bits
    new SecureRandom().nextBytes(buffer);

    Base32 base32 = new Base32();
    return base32.encodeToString(buffer).replace("=", "");
}


}
