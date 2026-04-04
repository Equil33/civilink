package com.civilink.civilink.controller;

import com.civilink.civilink.dto.report.CreateReportRequest;
import com.civilink.civilink.dto.report.ReportInstitutionStatsResponse;
import com.civilink.civilink.dto.report.ReportResponse;
import com.civilink.civilink.dto.report.UpdateReportRequest;
import com.civilink.civilink.dto.report.UpdateStatusRequest;
import com.civilink.civilink.exception.ApiException;
import com.civilink.civilink.service.ReportService;
import jakarta.validation.Valid;
import java.io.IOException;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/civilink/reports")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping
    public ResponseEntity<List<ReportResponse>> fetchReports(
        @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        return ResponseEntity.ok(reportService.fetchReports(authorization));
    }

    @GetMapping("/mine")
    public ResponseEntity<List<ReportResponse>> fetchMyReports(
        @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        return ResponseEntity.ok(reportService.fetchMyReports(authorization));
    }

    @GetMapping("/institution")
    public ResponseEntity<List<ReportResponse>> fetchInstitutionReports(
        @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        return ResponseEntity.ok(reportService.fetchInstitutionReports(authorization));
    }

    @GetMapping("/institution/stats")
    public ResponseEntity<ReportInstitutionStatsResponse> fetchInstitutionStats(
        @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        return ResponseEntity.ok(reportService.fetchInstitutionStats(authorization));
    }

    @PostMapping
    public ResponseEntity<ReportResponse> createReport(
        @Valid @RequestBody CreateReportRequest request,
        @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        return ResponseEntity.ok(reportService.createReport(request, authorization));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Void> updateStatus(
        @PathVariable("id") Long id,
        @Valid @RequestBody UpdateStatusRequest request,
        @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        reportService.updateStatus(id, request.getStatus(), authorization);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/vote")
    public ResponseEntity<Void> incrementVote(@PathVariable("id") Long id) {
        reportService.incrementVote(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ReportResponse> updateReport(
        @PathVariable("id") Long id,
        @Valid @RequestBody UpdateReportRequest request,
        @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        return ResponseEntity.ok(reportService.updateReport(id, request, authorization));
    }

    @PostMapping("/{id}/photo")
    public ResponseEntity<ReportResponse> uploadReportPhoto(
        @PathVariable("id") Long id,
        @RequestPart("file") MultipartFile file,
        @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        try {
            return ResponseEntity.ok(
                reportService.addReportPhoto(id, file.getBytes(), file.getOriginalFilename(), authorization)
            );
        } catch (IOException ex) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "Lecture de la photo impossible");
        }
    }

    @PostMapping("/{id}/resolution-photo")
    public ResponseEntity<ReportResponse> uploadResolutionPhoto(
        @PathVariable("id") Long id,
        @RequestPart("file") MultipartFile file,
        @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        try {
            return ResponseEntity.ok(
                reportService.addResolutionPhoto(id, file.getBytes(), file.getOriginalFilename(), authorization)
            );
        } catch (IOException ex) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "Lecture de la photo impossible");
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReport(
        @PathVariable("id") Long id,
        @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        reportService.deleteReport(id, authorization);
        return ResponseEntity.noContent().build();
    }
}
