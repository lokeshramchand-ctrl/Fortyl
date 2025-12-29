package com.aegis.auth.util;

import java.util.Date;

import org.springframework.stereotype.Service;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

@Service
public class JWTUtil {
  //TODO: Should fill this up with a JWT Token
  private final String secret = "super-secret-key-change";

  public String generateToken(String subject) {
    return Jwts.builder()
        .subject(subject)
        .issuedAt(new Date())
        .expiration(new Date(System.currentTimeMillis() + 86400000)) // 1 day
        .signWith(Keys.hmacShaKeyFor(secret.getBytes()))
        .compact();
  }

  public String extractSubject(String token) {
    return Jwts.parser()
        .verifyWith(Keys.hmacShaKeyFor(secret.getBytes()))
        .build()
        .parseSignedClaims(token)
        .getPayload()
        .getSubject();
  }
}
