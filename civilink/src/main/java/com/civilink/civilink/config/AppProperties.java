package com.civilink.civilink.config;

import java.util.ArrayList;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app")
public class AppProperties {

    private final Security security = new Security();
    private final Cors cors = new Cors();
    private String uploadDir = "uploads";

    public Security getSecurity() {
        return security;
    }

    public Cors getCors() {
        return cors;
    }

    public String getUploadDir() {
        return uploadDir;
    }

    public void setUploadDir(String uploadDir) {
        this.uploadDir = uploadDir;
    }

    public static class Security {
        private String tokenSecret = "change-this-secret-key-for-prod";
        private long accessTokenExpirationSeconds = 3600;
        private long refreshTokenExpirationSeconds = 604800;

        public String getTokenSecret() {
            return tokenSecret;
        }

        public void setTokenSecret(String tokenSecret) {
            this.tokenSecret = tokenSecret;
        }

        public long getAccessTokenExpirationSeconds() {
            return accessTokenExpirationSeconds;
        }

        public void setAccessTokenExpirationSeconds(long accessTokenExpirationSeconds) {
            this.accessTokenExpirationSeconds = accessTokenExpirationSeconds;
        }

        public long getRefreshTokenExpirationSeconds() {
            return refreshTokenExpirationSeconds;
        }

        public void setRefreshTokenExpirationSeconds(long refreshTokenExpirationSeconds) {
            this.refreshTokenExpirationSeconds = refreshTokenExpirationSeconds;
        }
    }

    public static class Cors {
        private List<String> allowedOrigins = new ArrayList<>(
            List.of("http://localhost:*", "http://127.0.0.1:*")
        );

        public List<String> getAllowedOrigins() {
            return allowedOrigins;
        }

        public void setAllowedOrigins(List<String> allowedOrigins) {
            this.allowedOrigins = allowedOrigins;
        }
    }
}
