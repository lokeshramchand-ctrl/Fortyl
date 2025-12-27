package com.aegis.auth.dto;

public record MfaConfirmRequest(
    String userId,
    String code
) {}
