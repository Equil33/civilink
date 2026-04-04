package com.civilink.civilink.service;

import com.civilink.civilink.dto.auth.AuthResponse;
import com.civilink.civilink.dto.auth.LoginRequest;
import com.civilink.civilink.dto.auth.RegisterCitizenRequest;
import com.civilink.civilink.dto.auth.RegisterOrganisationRequest;

public interface AuthService {

    AuthResponse registerCitizen(RegisterCitizenRequest request);

    AuthResponse registerOrganisation(RegisterOrganisationRequest request);

    AuthResponse login(LoginRequest request);

    AuthResponse refreshToken(String refreshToken);
}

