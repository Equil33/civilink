package com.civilink.civilink.service.impl;

import com.civilink.civilink.exception.ApiException;
import com.civilink.civilink.config.AppProperties;
import com.civilink.civilink.service.TokenPrincipal;
import com.civilink.civilink.service.TokenService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class TokenServiceImpl implements TokenService {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private final String tokenSecret;
    private final long accessTokenExpirationSeconds;
    private final long refreshTokenExpirationSeconds;

    public TokenServiceImpl(AppProperties appProperties) {
        AppProperties.Security security = appProperties.getSecurity();
        this.tokenSecret = security.getTokenSecret();
        this.accessTokenExpirationSeconds = security.getAccessTokenExpirationSeconds();
        this.refreshTokenExpirationSeconds = security.getRefreshTokenExpirationSeconds();
    }

    @Override
    public String createAccessToken(Long userId, String email, String role) {
        return createToken(userId, email, role, "access", accessTokenExpirationSeconds);
    }

    @Override
    public String createRefreshToken(Long userId, String email, String role) {
        return createToken(userId, email, role, "refresh", refreshTokenExpirationSeconds);
    }

    @Override
    public TokenPrincipal parseToken(String token, String expectedType) {
        try {
            String[] parts = token.split("\\.");
            if (parts.length != 3) {
                throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid token format");
            }

            String signature = sign(parts[0] + "." + parts[1]);
            if (!signature.equals(parts[2])) {
                throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid token signature");
            }

            String payloadJson = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);
            Map<String, Object> payload = OBJECT_MAPPER.readValue(payloadJson, new TypeReference<>() {
            });

            Long userId = Long.valueOf(payload.get("user_id").toString());
            String email = payload.get("sub").toString();
            String role = payload.get("role").toString();
            String tokenType = payload.get("token_type").toString();
            long exp = Long.parseLong(payload.get("exp").toString());

            if (!expectedType.equals(tokenType)) {
                throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid token type");
            }
            if (Instant.now().getEpochSecond() > exp) {
                throw new ApiException(HttpStatus.UNAUTHORIZED, "Token expired");
            }

            return new TokenPrincipal(userId, email, role, tokenType, exp);
        } catch (ApiException exception) {
            throw exception;
        } catch (Exception exception) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid token");
        }
    }

    private String createToken(Long userId, String email, String role, String tokenType, long expiresInSeconds) {
        try {
            Map<String, Object> header = Map.of("alg", "HS256", "typ", "JWT");
            long iat = Instant.now().getEpochSecond();
            long exp = iat + expiresInSeconds;

            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("sub", email);
            payload.put("user_id", userId);
            payload.put("role", role);
            payload.put("token_type", tokenType);
            payload.put("iat", iat);
            payload.put("exp", exp);

            String encodedHeader = base64Url(OBJECT_MAPPER.writeValueAsBytes(header));
            String encodedPayload = base64Url(OBJECT_MAPPER.writeValueAsBytes(payload));
            String unsigned = encodedHeader + "." + encodedPayload;
            return unsigned + "." + sign(unsigned);
        } catch (Exception exception) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "Unable to generate token");
        }
    }

    private String base64Url(byte[] raw) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(raw);
    }

    private String sign(String unsignedToken) {
        try {
            Mac hmac = Mac.getInstance("HmacSHA256");
            hmac.init(new SecretKeySpec(tokenSecret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return base64Url(hmac.doFinal(unsignedToken.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception exception) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "Unable to sign token");
        }
    }
}

