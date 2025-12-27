package com.aegis.auth.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.time.Instant;

import org.apache.commons.codec.binary.Base32;

public class TotpUtil {

    private static final int TIME_STEP = 30;
    private static final int DIGITS = 6;

    public static boolean verifyCode(String base32Secret, String code) {
        long timeWindow = Instant.now().getEpochSecond() / TIME_STEP;

        // allow ±1 window for clock drift
        for (long i = -1; i <= 1; i++) {
            String candidate = generateTotp(base32Secret, timeWindow + i);
            if (candidate.equals(code)) {
                return true;
            }
        }
        return false;
    }

    private static String generateTotp(String base32Secret, long timeWindow) {
        try {
            Base32 base32 = new Base32();
            byte[] key = base32.decode(base32Secret);

            ByteBuffer buffer = ByteBuffer.allocate(8);
            buffer.putLong(timeWindow);
            byte[] timeBytes = buffer.array();

            Mac mac = Mac.getInstance("HmacSHA1");
            mac.init(new SecretKeySpec(key, "HmacSHA1"));
            byte[] hash = mac.doFinal(timeBytes);

            int offset = hash[hash.length - 1] & 0xF;
            int binary =
                ((hash[offset] & 0x7f) << 24) |
                ((hash[offset + 1] & 0xff) << 16) |
                ((hash[offset + 2] & 0xff) << 8) |
                (hash[offset + 3] & 0xff);

            int otp = binary % (int) Math.pow(10, DIGITS);

            return String.format("%0" + DIGITS + "d", otp);

        } catch (GeneralSecurityException e) {
            throw new RuntimeException("TOTP generation failed", e);
        }
    }
}
