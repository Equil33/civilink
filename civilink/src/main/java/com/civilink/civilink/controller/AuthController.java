package com.civilink.civilink.controller;

import com.civilink.civilink.dto.auth.AuthResponse;
import com.civilink.civilink.dto.auth.LoginRequest;
import com.civilink.civilink.dto.auth.RefreshTokenRequest;
import com.civilink.civilink.dto.auth.RegisterCitizenRequest;
import com.civilink.civilink.dto.auth.RegisterOrganisationRequest;
import com.civilink.civilink.entity.AppUser;
import com.civilink.civilink.repository.AppUserRepository;
import com.civilink.civilink.service.AuthService;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/civilink/auth")
public class AuthController {

    private final AuthService authService;
    private final AppUserRepository appUserRepository;

    public AuthController(AuthService authService, AppUserRepository appUserRepository) {
        this.authService = authService;
        this.appUserRepository = appUserRepository;
    }

    @GetMapping("/users")
    public ResponseEntity<Map<String, Object>> listAllUsers() {
        List<AppUser> users = appUserRepository.findAll();
        Map<String, Object> response = new HashMap<>();
        response.put("total", users.size());
        response.put("users", users);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register/citoyen")
    public ResponseEntity<AuthResponse> registerCitizen(@Valid @RequestBody RegisterCitizenRequest request) {
        return ResponseEntity.ok(authService.registerCitizen(request));
    }

    @PostMapping("/register/organisation")
    public ResponseEntity<AuthResponse> registerOrganisation(@Valid @RequestBody RegisterOrganisationRequest request) {
        return ResponseEntity.ok(authService.registerOrganisation(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/token/refresh")
    public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(authService.refreshToken(request.getRefresh()));
    }
}

