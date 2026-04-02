package com.civilink.civilink.dto.report;

import jakarta.validation.constraints.NotBlank;
import java.util.ArrayList;
import java.util.List;

public class UpdateReportRequest {

    @NotBlank
    private String title;

    @NotBlank
    private String description;

    @NotBlank
    private String category;

    @NotBlank
    private String quartierId;

    @NotBlank
    private String address;

    private Double latitude;
    private Double longitude;
    private List<String> nearbyOrganisations = new ArrayList<>();

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

    public String getQuartierId() {
        return quartierId;
    }

    public void setQuartierId(String quartierId) {
        this.quartierId = quartierId;
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
}

