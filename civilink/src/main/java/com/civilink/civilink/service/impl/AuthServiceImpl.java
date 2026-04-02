package com.civilink.civilink.service.impl;

import com.civilink.civilink.dto.auth.AuthResponse;
import com.civilink.civilink.dto.auth.LoginRequest;
import com.civilink.civilink.dto.auth.RegisterCitizenRequest;
import com.civilink.civilink.dto.auth.RegisterOrganisationRequest;
import com.civilink.civilink.entity.AppUser;
import com.civilink.civilink.exception.ApiException;
import com.civilink.civilink.repository.AppUserRepository;
import com.civilink.civilink.service.AuthService;
import com.civilink.civilink.service.TokenPrincipal;
import com.civilink.civilink.service.TokenService;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class AuthServiceImpl implements AuthService {
    private static final Logger logger = LoggerFactory.getLogger(AuthServiceImpl.class);

    private final AppUserRepository appUserRepository;
    private final TokenService tokenService;
    private final PasswordEncoder passwordEncoder;

    public AuthServiceImpl(
        AppUserRepository appUserRepository,
        TokenService tokenService,
        PasswordEncoder passwordEncoder
    ) {
        this.appUserRepository = appUserRepository;
        this.tokenService = tokenService;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public AuthResponse registerCitizen(RegisterCitizenRequest request) {
        validateUniqueEmail(request.getEmail());

        AppUser user = new AppUser();
        user.setRole("citoyen");
        user.setEmail(normalizeEmail(request.getEmail()));
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setPhone(request.getPhone().trim());
        user.setNom(request.getNom().trim());
        user.setPrenoms(request.getPrenoms().trim());
        user.setIdType(request.getIdType().trim());
        user.setIdNumber(request.getIdNumber().trim());
        user.setIdExpirationDate(request.getIdExpirationDate().trim());
        user.setDisplayName((request.getNom() + " " + request.getPrenoms()).trim());

        AppUser saved = appUserRepository.save(user);
        logger.info("Citizen registered: id={}, email={}, role={}", saved.getId(), saved.getEmail(), saved.getRole());
        return buildAuthResponse(saved, true);
    }

    @Override
    public AuthResponse registerOrganisation(RegisterOrganisationRequest request) {
        validateUniqueEmail(request.getEmail());

        AppUser user = new AppUser();
        user.setRole("organisation");
        user.setEmail(normalizeEmail(request.getEmail()));
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setPhone(request.getPhone().trim());
        user.setOrgType(request.getOrgType().trim());
        user.setServiceCardNumber(request.getServiceCardNumber().trim());
        user.setCommune(request.getCommune().trim());
        user.setDisplayName(buildOrganisationDisplayName(user.getOrgType(), user.getCommune()));

        AppUser saved = appUserRepository.save(user);
        logger.info(
            "Organisation registered: id={}, email={}, orgType={}, commune={}",
            saved.getId(),
            saved.getEmail(),
            saved.getOrgType(),
            saved.getCommune()
        );
        return buildAuthResponse(saved, false);
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        String normalizedEmail = normalizeEmail(request.getEmail());
        logger.info("Tentative de connexion pour email: {}, role: {}", normalizedEmail, request.getRole());

        AppUser user = appUserRepository.findByEmailIgnoreCase(normalizedEmail)
            .orElseThrow(() -> {
                logger.warn("Utilisateur non trouvé pour email: {}", normalizedEmail);
                return new ApiException(HttpStatus.UNAUTHORIZED, "Email ou mot de passe invalide");
            });

        logger.info("Utilisateur trouvé: id={}, email={}, role={}", user.getId(), user.getEmail(), user.getRole());

        if (!matchesPassword(request.getPassword(), user)) {
            logger.warn("Mot de passe incorrect pour utilisateur: {}", user.getId());
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Email ou mot de passe invalide");
        }

        String requestedRole = request.getRole().trim().toLowerCase(Locale.ROOT);
        logger.info("Rôle demandé: {}, rôle utilisateur: {}", requestedRole, user.getRole());

        if (!requestedRole.equals(user.getRole())) {
            logger.warn("Rôle incompatible - demandé: {}, utilisateur: {}", requestedRole, user.getRole());
            throw new ApiException(HttpStatus.FORBIDDEN, "Role incompatible avec ce compte");
        }

        if ("organisation".equals(requestedRole)
            && request.getOrgType() != null
            && !request.getOrgType().isBlank()
            && user.getOrgType() != null
            && !request.getOrgType().trim().equalsIgnoreCase(user.getOrgType())) {
            logger.warn("Type d'organisation invalide - demandé: {}, utilisateur: {}", request.getOrgType(), user.getOrgType());
            throw new ApiException(HttpStatus.FORBIDDEN, "Type d'organisation invalide");
        }

        logger.info("Connexion réussie pour utilisateur: {}", user.getId());
        return buildAuthResponse(user, "citoyen".equals(user.getRole()));
    }

    @Override
    public AuthResponse refreshToken(String refreshToken) {
        TokenPrincipal principal = tokenService.parseToken(refreshToken, "refresh");
        AppUser user = appUserRepository.findById(principal.userId())
            .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Utilisateur introuvable"));

        AuthResponse response = new AuthResponse();
        response.setAccessToken(tokenService.createAccessToken(user.getId(), user.getEmail(), user.getRole()));
        response.setRefreshToken(tokenService.createRefreshToken(user.getId(), user.getEmail(), user.getRole()));
        response.setName(user.getDisplayName());
        response.setRole(user.getRole());
        response.setUserId(String.valueOf(user.getId()));
        response.setCitizenProfile(citizenProfileOrNull(user));
        response.setOrganisationProfile(organisationProfileOrNull(user));
        return response;
    }

    private void validateUniqueEmail(String email) {
        if (appUserRepository.existsByEmailIgnoreCase(normalizeEmail(email))) {
            throw new ApiException(HttpStatus.CONFLICT, "Un compte existe deja pour cet email");
        }
    }

    private AuthResponse buildAuthResponse(AppUser user, boolean includeCitizenProfile) {
        AuthResponse response = new AuthResponse();
        response.setName(user.getDisplayName());
        response.setRole(user.getRole());
        response.setUserId(String.valueOf(user.getId()));
        response.setAccessToken(tokenService.createAccessToken(user.getId(), user.getEmail(), user.getRole()));
        response.setRefreshToken(tokenService.createRefreshToken(user.getId(), user.getEmail(), user.getRole()));
        response.setCitizenProfile(includeCitizenProfile ? citizenProfileOrNull(user) : Map.of());
        response.setOrganisationProfile("organisation".equals(user.getRole()) ? organisationProfileOrNull(user) : Map.of());
        return response;
    }

    private Map<String, String> citizenProfileOrNull(AppUser user) {
        Map<String, String> profile = new LinkedHashMap<>();
        if (user.getNom() != null) {
            profile.put("nom", user.getNom());
        }
        if (user.getPrenoms() != null) {
            profile.put("prenoms", user.getPrenoms());
        }
        if (user.getIdType() != null) {
            profile.put("idType", user.getIdType());
        }
        if (user.getIdNumber() != null) {
            profile.put("idNumber", user.getIdNumber());
        }
        if (user.getIdExpirationDate() != null) {
            profile.put("idExpirationDate", user.getIdExpirationDate());
        }
        if (user.getPhone() != null) {
            profile.put("phone", user.getPhone());
        }
        if (user.getEmail() != null) {
            profile.put("email", user.getEmail());
        }
        return profile;
    }

    private Map<String, String> organisationProfileOrNull(AppUser user) {
        Map<String, String> profile = new LinkedHashMap<>();
        if (user.getOrgType() != null) {
            profile.put("orgType", user.getOrgType());
        }
        if (user.getCommune() != null) {
            profile.put("commune", user.getCommune());
        }
        if (user.getPhone() != null) {
            profile.put("phone", user.getPhone());
        }
        if (user.getEmail() != null) {
            profile.put("email", user.getEmail());
        }
        String displayName = buildOrganisationDisplayName(user.getOrgType(), user.getCommune());
        if (!displayName.isBlank()) {
            profile.put("orgName", displayName);
        }
        return profile;
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private String buildOrganisationDisplayName(String orgType, String commune) {
        String normalizedType = normalize(orgType).replace('_', ' ');
        String label = switch (normalizedType) {
            case "mairie" -> "mairie";
            case "police" -> "police";
            case "gendarmerie" -> "gendarmerie";
            case "sapeur pompier", "sapeur-pompier" -> "sapeurs-pompiers";
            case "voirie" -> "voirie";
            case "dsr" -> "dsr";
            case "cms" -> "cms";
            case "clinique" -> "clinique";
            case "hopital public", "hopital" -> "hopital public";
            default -> normalizedType.isBlank() ? "institution" : normalizedType;
        };

        String communeLabel = normalize(commune);
        if (communeLabel.isBlank()) {
            return label;
        }
        return label + " de " + communeLabel;
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        return value.trim().toLowerCase(Locale.ROOT);
    }

    private boolean matchesPassword(String rawPassword, AppUser user) {
        String storedHash = user.getPasswordHash();
        if (storedHash == null || storedHash.isBlank()) {
            return false;
        }

        if (storedHash.startsWith("$2a$") || storedHash.startsWith("$2b$") || storedHash.startsWith("$2y$")) {
            return passwordEncoder.matches(rawPassword, storedHash);
        }

        // Compatibilite legacy: anciens comptes SHA-256, migrer vers BCrypt au prochain login valide.
        String legacyHash = legacySha256(rawPassword);
        if (!storedHash.equals(legacyHash)) {
            return false;
        }

        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        appUserRepository.save(user);
        return true;
    }

    private String legacySha256(String rawPassword) {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(rawPassword.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder builder = new StringBuilder();
            for (byte b : hash) {
                builder.append(String.format("%02x", b));
            }
            return builder.toString();
        } catch (Exception exception) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "Impossible de traiter le mot de passe");
        }
    }
}

