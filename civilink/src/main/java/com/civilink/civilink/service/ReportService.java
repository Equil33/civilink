package com.civilink.civilink.service;

import com.civilink.civilink.dto.report.CreateReportRequest;
import com.civilink.civilink.dto.report.ReportInstitutionStatsResponse;
import com.civilink.civilink.dto.report.ReportResponse;
import com.civilink.civilink.dto.report.UpdateReportRequest;
import java.util.List;

public interface ReportService {

    List<ReportResponse> fetchReports(String accessToken);

    List<ReportResponse> fetchMyReports(String accessToken);
    
    List<ReportResponse> fetchInstitutionReports(String accessToken);

    ReportInstitutionStatsResponse fetchInstitutionStats(String accessToken);

    ReportResponse createReport(CreateReportRequest request, String accessToken);

    void updateStatus(Long reportId, String status, String accessToken);

    void incrementVote(Long reportId);

    ReportResponse updateReport(Long reportId, UpdateReportRequest request, String accessToken);

    ReportResponse addResolutionPhoto(Long reportId, byte[] content, String filename, String accessToken);

    void deleteReport(Long reportId, String accessToken);
}

