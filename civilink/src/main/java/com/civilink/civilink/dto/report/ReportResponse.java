package com.civilink.civilink.dto.report;

import java.util.ArrayList;
import java.util.List;

public class ReportResponse {

    private String id;
    private String title;
    private String description;
    private String category;
    private String status;
    private String quartier;
    private String address;
    private Double latitude;
    private Double longitude;
    private List<String> nearbyOrganisations = new ArrayList<>();
    private List<String> resolutionPhotos = new ArrayList<>();
    private String date;
    private int votes;
    private String reporterId;
    private String reporterType;
    private String createdAt;
    private boolean canEdit;
    private boolean canDelete;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getQuartier() {
        return quartier;
    }

    public void setQuartier(String quartier) {
        this.quartier = quartier;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public List<String> getNearbyOrganisations() {
        return nearbyOrganisations;
    }

    public void setNearbyOrganisations(List<String> nearbyOrganisations) {
        this.nearbyOrganisations = nearbyOrganisations;
    }

    public List<String> getResolutionPhotos() {
        return resolutionPhotos;
    }

    public void setResolutionPhotos(List<String> resolutionPhotos) {
        this.resolutionPhotos = resolutionPhotos;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public int getVotes() {
        return votes;
    }

    public void setVotes(int votes) {
        this.votes = votes;
    }

    public String getReporterId() {
        return reporterId;
    }

    public void setReporterId(String reporterId) {
        this.reporterId = reporterId;
    }

    public String getReporterType() {
        return reporterType;
    }

    public void setReporterType(String reporterType) {
        this.reporterType = reporterType;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isCanEdit() {
        return canEdit;
    }

    public void setCanEdit(boolean canEdit) {
        this.canEdit = canEdit;
    }

    public boolean isCanDelete() {
        return canDelete;
    }

    public void setCanDelete(boolean canDelete) {
        this.canDelete = canDelete;
    }
}

