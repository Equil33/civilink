package com.civilink.civilink.service;

public record TokenPrincipal(Long userId, String email, String role, String tokenType, long exp) {
}

