package com.civilink.civilink.service;

public interface TokenService {

    String createAccessToken(Long userId, String email, String role);

    String createRefreshToken(Long userId, String email, String role);

    TokenPrincipal parseToken(String token, String expectedType);
}

