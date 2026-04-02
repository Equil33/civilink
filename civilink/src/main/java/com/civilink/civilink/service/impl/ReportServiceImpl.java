package com.civilink.civilink.service.impl;

import com.civilink.civilink.dto.report.CreateReportRequest;
import com.civilink.civilink.dto.report.ReportInstitutionStatsResponse;
import com.civilink.civilink.dto.report.ReportResponse;
import com.civilink.civilink.dto.report.UpdateReportRequest;
import com.civilink.civilink.entity.AppUser;
import com.civilink.civilink.entity.Institution;
import com.civilink.civilink.entity.Quartier;
import com.civilink.civilink.entity.Report;
import com.civilink.civilink.exception.ApiException;
import com.civilink.civilink.repository.AppUserRepository;
import com.civilink.civilink.repository.ReportRepository;
import com.civilink.civilink.service.QuartierService;
import com.civilink.civilink.service.ReportRoutingService;
import com.civilink.civilink.service.ReportService;
import com.civilink.civilink.service.TokenPrincipal;
import com.civilink.civilink.service.TokenService;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import java.util.UUID;
import java.util.function.Function;
import org.springframework.http.HttpStatus;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class ReportServiceImpl implements ReportService {

    private static final List<String> ALLOWED_STATUSES = List.of("nouveau", "en_cours", "finalise", "resolu");
    private static final Map<String, String> QUARTIER_TO_COMMUNE = new HashMap<>();

    static {
        QUARTIER_TO_COMMUNE.put("baguida", "golfe 6");
        QUARTIER_TO_COMMUNE.put("adidogome", "golfe 7");
        QUARTIER_TO_COMMUNE.put("tokoin", "golfe 2");
        QUARTIER_TO_COMMUNE.put("agoe", "agoe-nyive 1");
        QUARTIER_TO_COMMUNE.put("avedji", "golfe 5");
        QUARTIER_TO_COMMUNE.put("nyekonakpoe", "golfe 4");
        QUARTIER_TO_COMMUNE.put("akodessewa", "golfe 1");
    }

    private final ReportRepository reportRepository;
    private final AppUserRepository appUserRepository;
    private final TokenService tokenService;
    private final QuartierService quartierService;
    private final ReportRoutingService reportRoutingService;
    @Value("${app.upload-dir:uploads}")
    private String uploadDir;

    public ReportServiceImpl(
        ReportRepository reportRepository,
        AppUserRepository appUserRepository,
        TokenService tokenService,
        QuartierService quartierService,
        ReportRoutingService reportRoutingService
    ) {
        this.reportRepository = reportRepository;
        this.appUserRepository = appUserRepository;
        this.tokenService = tokenService;
        this.quartierService = quartierService;
        this.reportRoutingService = reportRoutingService;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportResponse> fetchReports(String accessToken) {
        Optional<Long> userId = parseUserIdOptional(accessToken);
        return reportRepository.findAllByOrderByCreatedAtDesc()
            .stream()
            .map(report -> toResponse(report, userId))
            .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportResponse> fetchMyReports(String accessToken) {
        Long userId = parseUserIdRequired(accessToken);
        return reportRepository.findByReporterIdOrderByCreatedAtDesc(String.valueOf(userId))
            .stream()
            .map(report -> toResponse(report, Optional.of(userId)))
            .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportResponse> fetchInstitutionReports(String accessToken) {
        InstitutionContext context = loadInstitutionContext(accessToken);
        return reportRepository.findAllByOrderByCreatedAtDesc()
            .stream()
            .filter(report -> isAssignedToInstitution(report, context))
            .map(report -> toResponse(report, Optional.empty()))
            .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ReportInstitutionStatsResponse fetchInstitutionStats(String accessToken) {
        InstitutionContext context = loadInstitutionContext(accessToken);
        List<Report> reports = reportRepository.findAllByOrderByCreatedAtDesc()
            .stream()
            .filter(report -> isAssignedToInstitution(report, context))
            .toList();

        ReportInstitutionStatsResponse response = new ReportInstitutionStatsResponse();
        response.setTotal(reports.size());
        response.setByStatus(buildCountMap(reports, Report::getStatus));
        response.setByCategory(buildCountMap(reports, Report::getCategory));
        return response;
    }

    @Override
    public ReportResponse createReport(CreateReportRequest request, String accessToken) {
        String effectiveReporterId = request.getReporterId().trim();
        String effectiveReporterType = request.getReporterType().trim();

        Optional<Long> userId = parseUserIdOptional(accessToken);
        if (userId.isPresent()) {
            effectiveReporterId = String.valueOf(userId.get());
            if (!"quick_guest".equalsIgnoreCase(effectiveReporterType)) {
                effectiveReporterType = "member";
            }
        }

        Report report = new Report();
        report.setTitle(request.getTitle().trim());
        report.setDescription(request.getDescription().trim());
        report.setCategory(request.getCategory().trim());
        report.setStatus("nouveau");
        report.setAddress(request.getAddress().trim());
        report.setLatitude(request.getLatitude());
        report.setLongitude(request.getLongitude());
        report.setNearbyOrganisations(new ArrayList<>(request.getNearbyOrganisations()));
        report.setVotes(0);
        report.setReporterId(effectiveReporterId);
        report.setReporterType(effectiveReporterType);

        if (request.getQuartierId() == null || request.getQuartierId().trim().isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "L'ID du quartier est requis");
        }

        Long quartierId;
        try {
            quartierId = Long.parseLong(request.getQuartierId().trim());
        } catch (NumberFormatException e) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "L'ID du quartier doit etre un nombre valide");
        }

        Quartier quartier = quartierService.getQuartierById(quartierId);
        if (quartier == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Quartier invalide");
        }
        report.setQuartier(quartier);
        report.setCommune(quartier.getCommune());

        Set<Institution> targetInstitutions = reportRoutingService.determineTargetInstitutions(report);
        report.setTargetInstitutions(targetInstitutions);

        Report saved = reportRepository.saveAndFlush(report);
        return toResponse(saved, userId);
    }

    @Override
    public void updateStatus(Long reportId, String status, String accessToken) {
        TokenPrincipal principal = parsePrincipalRequired(accessToken);
        AppUser user = appUserRepository.findById(principal.userId())
            .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Institution introuvable"));
        if (!"organisation".equals(user.getRole())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Acces reserve aux institutions");
        }

        String normalizedStatus = normalizeStatus(status);
        if (!ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Statut invalide");
        }

        Report report = getReport(reportId);
        if (!isAssignedToInstitution(report, new InstitutionContext(normalizeOrgType(user.getOrgType()), normalize(user.getCommune())))) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Signalement non assigne a cette institution");
        }

        report.setStatus(normalizedStatus);
        reportRepository.save(report);
    }

    @Override
    public void incrementVote(Long reportId) {
        Report report = getReport(reportId);
        report.setVotes(report.getVotes() + 1);
        reportRepository.save(report);
    }

    @Override
    public ReportResponse updateReport(Long reportId, UpdateReportRequest request, String accessToken) {
        Long userId = parseUserIdRequired(accessToken);
        Report report = getReport(reportId);
        checkOwnership(userId, report);

        report.setTitle(request.getTitle().trim());
        report.setDescription(request.getDescription().trim());
        report.setCategory(request.getCategory().trim());
        Quartier quartier = quartierService.getQuartierById(Long.parseLong(request.getQuartierId().trim()));
        if (quartier == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Quartier invalide");
        }
        report.setQuartier(quartier);
        report.setCommune(quartier.getCommune());
        report.setAddress(request.getAddress().trim());
        report.setLatitude(request.getLatitude());
        report.setLongitude(request.getLongitude());
        report.setNearbyOrganisations(new ArrayList<>(request.getNearbyOrganisations()));

        Report saved = reportRepository.save(report);
        return toResponse(saved, Optional.of(userId));
    }

    @Override
    public ReportResponse addResolutionPhoto(Long reportId, byte[] content, String filename, String accessToken) {
        if (content == null || content.length == 0) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Fichier photo requis");
        }
        if (filename == null || filename.isBlank()) {
            filename = "photo";
        }

        TokenPrincipal principal = parsePrincipalRequired(accessToken);
        AppUser user = appUserRepository.findById(principal.userId())
            .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Institution introuvable"));
        if (!"organisation".equals(user.getRole())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Acces reserve aux institutions");
        }

        Report report = getReport(reportId);
        if (!isAssignedToInstitution(report, new InstitutionContext(normalizeOrgType(user.getOrgType()), normalize(user.getCommune())))) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Signalement non assigne a cette institution");
        }

        String safeExt = "";
        int dotIndex = filename.lastIndexOf('.');
        if (dotIndex >= 0 && dotIndex < filename.length() - 1) {
            String ext = filename.substring(dotIndex + 1).toLowerCase(Locale.ROOT);
            if (ext.length() <= 6) {
                safeExt = "." + ext;
            }
        }
        String storedName = "resolution-" + UUID.randomUUID() + safeExt;
        Path targetDir = Paths.get(uploadDir, "reports", String.valueOf(reportId)).toAbsolutePath().normalize();
        try {
            Files.createDirectories(targetDir);
            Path target = targetDir.resolve(storedName);
            Files.write(target, content);
        } catch (IOException ex) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "Impossible d'enregistrer la photo");
        }

        String url = "/uploads/reports/" + reportId + "/" + storedName;
        List<String> photos = report.getResolutionPhotos();
        photos.add(url);
        report.setResolutionPhotos(photos);
        Report saved = reportRepository.save(report);
        return toResponse(saved, Optional.empty());
    }

    @Override
    public void deleteReport(Long reportId, String accessToken) {
        Long userId = parseUserIdRequired(accessToken);
        Report report = getReport(reportId);
        checkOwnership(userId, report);
        reportRepository.delete(report);
    }

    private Report getReport(Long reportId) {
        return reportRepository.findById(reportId)
            .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Signalement introuvable"));
    }

    private void checkOwnership(Long userId, Report report) {
        if (!String.valueOf(userId).equals(report.getReporterId())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Vous ne pouvez modifier que vos signalements");
        }
        if (!"member".equals(report.getReporterType())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Signalement non modifiable");
        }
    }

    private Optional<Long> parseUserIdOptional(String rawHeader) {
        if (rawHeader == null || rawHeader.isBlank()) {
            return Optional.empty();
        }
        String token = stripBearer(rawHeader);
        if (token.isBlank()) {
            return Optional.empty();
        }
        try {
            TokenPrincipal principal = tokenService.parseToken(token, "access");
            return Optional.of(principal.userId());
        } catch (ApiException ignored) {
            return Optional.empty();
        }
    }

    private Long parseUserIdRequired(String rawHeader) {
        if (rawHeader == null || rawHeader.isBlank()) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Authentification requise");
        }
        String token = stripBearer(rawHeader);
        if (token.isBlank()) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Authentification requise");
        }
        return tokenService.parseToken(token, "access").userId();
    }

    private TokenPrincipal parsePrincipalRequired(String rawHeader) {
        if (rawHeader == null || rawHeader.isBlank()) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Authentification requise");
        }
        String token = stripBearer(rawHeader);
        if (token.isBlank()) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Authentification requise");
        }
        return tokenService.parseToken(token, "access");
    }

    private String stripBearer(String rawHeader) {
        if (rawHeader == null) {
            return "";
        }
        if (rawHeader.startsWith("Bearer ")) {
            return rawHeader.substring("Bearer ".length()).trim();
        }
        return rawHeader.trim();
    }

    private boolean isAssignedToInstitution(Report report, InstitutionContext context) {
        if (report == null || report.getQuartier() == null || context == null) {
            return false;
        }
        if (report.getTargetInstitutions() != null && !report.getTargetInstitutions().isEmpty()) {
            return report.getTargetInstitutions()
                .stream()
                .anyMatch(institution -> matchesInstitution(institution, context));
        }
        Set<String> recipients = recipientsForReport(report);
        if ("mairie".equals(context.orgType())) {
            String reportCommune = communeForQuartier(report.getQuartier().getName());
            return recipients.contains("mairie") && reportCommune.equals(context.commune());
        }
        return recipients.contains(context.orgType());
    }

    private Set<String> recipientsForReport(Report report) {
        String category = normalize(report.getCategory());
        if (category.contains("accident")) {
            return new HashSet<>(List.of("mairie", "dsr", "gendarmerie", "pompiers", "police"));
        }
        if (category.contains("degat")) {
            return new HashSet<>(List.of("mairie"));
        }
        if (category.contains("dechet")) {
            return new HashSet<>(List.of("mairie", "voirie"));
        }
        if (category.contains("inond")) {
            return new HashSet<>(List.of("mairie", "pompiers"));
        }
        if (category.contains("incend")) {
            return new HashSet<>(List.of("pompiers", "police"));
        }
        return new HashSet<>(List.of("mairie"));
    }

    private String normalizeStatus(String raw) {
        String normalized = normalize(raw).replace(' ', '_');
        if ("resolu".equals(normalized)) {
            return "finalise";
        }
        return normalized;
    }

    private String communeForQuartier(String quartier) {
        String normalized = normalize(quartier);
        return QUARTIER_TO_COMMUNE.getOrDefault(normalized, "inconnu");
    }

    private String normalizeOrgType(String orgType) {
        String normalized = normalize(orgType).replace(' ', '_');
        if (normalized.equals("hopital") || normalized.equals("hopital_public")) {
            return "hopital_public";
        }
        return normalized;
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        return value.trim().toLowerCase(Locale.ROOT);
    }

    private ReportResponse toResponse(Report report, Optional<Long> viewerUserId) {
        if (report == null) {
            return null;
        }
        String quartierName = null;
        try {
            if (report.getQuartier() != null) {
                quartierName = report.getQuartier().getName();
            }
        } catch (RuntimeException ignored) {
            quartierName = null;
        }

        boolean canEditDelete = viewerUserId.isPresent()
            && "member".equals(report.getReporterType())
            && String.valueOf(viewerUserId.get()).equals(report.getReporterId());

        ReportResponse response = new ReportResponse();
        response.setId(String.valueOf(report.getId()));
        response.setTitle(report.getTitle());
        response.setDescription(report.getDescription());
        response.setCategory(report.getCategory());
        response.setStatus(report.getStatus());
        response.setQuartier(quartierName == null ? "Inconnu" : quartierName);
        response.setAddress(report.getAddress());
        response.setLatitude(report.getLatitude());
        response.setLongitude(report.getLongitude());
        response.setNearbyOrganisations(report.getNearbyOrganisations());
        response.setResolutionPhotos(report.getResolutionPhotos());
        response.setDate(report.getDate());
        response.setVotes(report.getVotes());
        response.setReporterId(report.getReporterId());
        response.setReporterType(report.getReporterType());
        response.setCreatedAt(report.getCreatedAt() == null ? null : report.getCreatedAt().toString());
        response.setCanEdit(canEditDelete);
        response.setCanDelete(canEditDelete);
        return response;
    }

    private InstitutionContext loadInstitutionContext(String accessToken) {
        TokenPrincipal principal = parsePrincipalRequired(accessToken);
        AppUser user = appUserRepository.findById(principal.userId())
            .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Institution introuvable"));

        if (!"organisation".equals(user.getRole())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Acces reserve aux institutions");
        }

        String organisationType = normalizeOrgType(user.getOrgType());
        String commune = normalize(user.getCommune());

        if (organisationType.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Type d'organisation non defini pour cet utilisateur");
        }
        if (commune.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Commune non definie pour cet utilisateur");
        }

        return new InstitutionContext(organisationType, commune);
    }

    private boolean matchesInstitution(Institution institution, InstitutionContext context) {
        if (institution == null) {
            return false;
        }
        String institutionType = normalizeOrgType(institution.getType());
        if (!institutionType.equals(context.orgType())) {
            return false;
        }
        if (institution.getCommune() == null || institution.getCommune().getName() == null) {
            return false;
        }
        return normalize(institution.getCommune().getName()).equals(context.commune());
    }

    private Map<String, Long> buildCountMap(List<Report> reports, Function<Report, String> extractor) {
        Map<String, Long> counts = new LinkedHashMap<>();
        reports.stream()
            .map(extractor)
            .map(this::normalize)
            .filter(value -> !value.isBlank())
            .sorted()
            .forEach(value -> counts.merge(value, 1L, Long::sum));
        return counts;
    }

    private record InstitutionContext(String orgType, String commune) {}
}
