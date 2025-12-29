package com.aegis.auth.dto;

public record AuthResponse(
  String token,
  Boolean mfaRequired,
  String userId
) {
  public static AuthResponse success(String token) {
    return new AuthResponse(token, false, null);
  }
  public static AuthResponse mfaRequired(String userId) {
    return new AuthResponse(null, true, userId);
  }
}
