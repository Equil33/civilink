package com.civilink.civilink.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Column;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.JoinTable;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.PrePersist;
import java.util.Set;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "reports")
public class Report {

    private static final DateTimeFormatter DISPLAY_DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, length = 4000)
    private String description;

    @Column(nullable = false)
    private String category;

    @Column(nullable = false)
    private String status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quartier_id", nullable = true)
    private Quartier quartier;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "commune_id", nullable = true)
    private Commune commune;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "report_institutions",
        joinColumns = @JoinColumn(name = "report_id"),
        inverseJoinColumns = @JoinColumn(name = "institution_id")
    )
    private Set<Institution> targetInstitutions;

    @Column(nullable = false)
    private String address;

    private Double latitude;
    private Double longitude;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "report_nearby_organisations", joinColumns = @JoinColumn(name = "report_id"))
    @Column(name = "organisation_name")
    private List<String> nearbyOrganisations = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "report_resolution_photos", joinColumns = @JoinColumn(name = "report_id"))
    @Column(name = "photo_url")
    private List<String> resolutionPhotos = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "report_photos", joinColumns = @JoinColumn(name = "report_id"))
    @Column(name = "photo_url")
    private List<String> photos = new ArrayList<>();

    @Column(nullable = false)
    private String date;

    @Column(nullable = false)
    private int votes;

    @Column(nullable = false)
    private String reporterId;

    @Column(nullable = false)
    private String reporterType;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void prePersist() {
        if (quartier == null) {
            throw new IllegalStateException("Bad state: quartier ne doit pas être vide");
        }
        if (commune == null) {
            throw new IllegalStateException("Bad state: commune ne doit pas être vide");
        }
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (date == null || date.isBlank()) {
            date = createdAt.format(DISPLAY_DATE_FORMAT);
        }
        if (status == null || status.isBlank()) {
            status = "nouveau";
        }
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
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

    public List<String> getPhotos() {
        return photos;
    }

    public void setPhotos(List<String> photos) {
        this.photos = photos;
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

    public Quartier getQuartier() {
        return quartier;
    }

    public void setQuartier(Quartier quartier) {
        this.quartier = quartier;
    }

    public Commune getCommune() {
        return commune;
    }

    public void setCommune(Commune commune) {
        this.commune = commune;
    }

    public Set<Institution> getTargetInstitutions() {
        return targetInstitutions;
    }

    public void setTargetInstitutions(Set<Institution> targetInstitutions) {
        this.targetInstitutions = targetInstitutions;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
