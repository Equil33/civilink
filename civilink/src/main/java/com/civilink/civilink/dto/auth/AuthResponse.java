package com.civilink.civilink.dto.auth;

import java.util.Map;

public class AuthResponse {

    private String name;
    private String role;
    private String userId;
    private String accessToken;
    private String refreshToken;
    private Map<String, String> citizenProfile;
    private Map<String, String> organisationProfile;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public Map<String, String> getCitizenProfile() {
        return citizenProfile;
    }

    public void setCitizenProfile(Map<String, String> citizenProfile) {
        this.citizenProfile = citizenProfile;
    }

    public Map<String, String> getOrganisationProfile() {
        return organisationProfile;
    }

    public void setOrganisationProfile(Map<String, String> organisationProfile) {
        this.organisationProfile = organisationProfile;
    }
}

