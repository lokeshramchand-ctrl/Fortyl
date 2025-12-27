package com.aegis.auth.service;

import com.aegis.auth.dto.MfaEnrollResponse;
import com.aegis.auth.entity.MfaSecret;
import com.aegis.auth.entity.MfaSecret.Status;
import com.aegis.auth.repository.MfaSecretRepository;
import com.aegis.auth.util.QrCodeUtil;
import com.eatthepath.otp.TimeBasedOneTimePasswordGenerator;
import org.apache.commons.codec.binary.Base32;
import org.springframework.stereotype.Service;

import javax.crypto.spec.SecretKeySpec;
import java.security.Key;
import java.security.SecureRandom;
import java.time.Instant;

@Service
public class MfaService {

    private final MfaSecretRepository repo;

    public MfaService(MfaSecretRepository repo) {
        this.repo = repo;
    }

    // ---------- ENROLL ----------
    public MfaEnrollResponse enroll(String userId) {

        String secret = generateSecret();

        String otpauth = String.format(
            "otpauth://totp/%s:%s?secret=%s&issuer=%s&digits=6&period=30",
            "Aegis", userId, secret, "Aegis"
        );

        MfaSecret entity = new MfaSecret();
        entity.setUserId(userId);
        entity.setEncryptedSecret(secret);
        entity.setStatus(Status.PENDING);

        repo.save(entity);

        String qrBase64 = QrCodeUtil.toBase64Png(otpauth);
        return new MfaEnrollResponse(qrBase64);
    }

    // ---------- CONFIRM ----------
    public boolean confirm(String userId, String code) {

        MfaSecret secretEntity = repo.findByUserId(userId)
            .orElseThrow(() -> new RuntimeException("MFA not enrolled"));

        if (secretEntity.getStatus() != Status.PENDING) {
            throw new RuntimeException("MFA already active or disabled");
        }

        boolean valid = verifyCode(secretEntity.getEncryptedSecret(), code);

        if (!valid) {
            throw new RuntimeException("Invalid MFA code");
        }

        secretEntity.setStatus(Status.ACTIVE);
        repo.save(secretEntity);

        return true;
    }

    // ---------- TOTP VERIFY (with ±1 window) ----------
    private boolean verifyCode(String base32Secret, String code) {

        try {
            Base32 base32 = new Base32();
            byte[] decodedKey = base32.decode(base32Secret);

            Key key = new SecretKeySpec(decodedKey, "HmacSHA1");

            TimeBasedOneTimePasswordGenerator totp =
                    new TimeBasedOneTimePasswordGenerator(); // default: 30s, 6 digits, SHA1

            Instant now = Instant.now();

            for (int i = -1; i <= 1; i++) {
                Instant t = now.plusSeconds(i * 30L);
                int expected = totp.generateOneTimePassword(key, t);
                if (String.format("%06d", expected).equals(code)) {
                    return true;
                }
            }
            return false;

        } catch (Exception e) {
            throw new RuntimeException("Error verifying TOTP", e);
        }
    }

    // ---------- SECRET GENERATOR ----------
    public String generateSecret() {
        byte[] buffer = new byte[20]; // 160 bits
        new SecureRandom().nextBytes(buffer);

        Base32 base32 = new Base32();
        return base32.encodeToString(buffer).replace("=", "");
    }
}
