package com.civilink.civilink.dto.quartier;

public class QuartierResponse {

    private Long id;
    private String name;
    private Long communeId;

    public QuartierResponse() {}

    public QuartierResponse(Long id, String name, Long communeId) {
        this.id = id;
        this.name = name;
        this.communeId = communeId;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Long getCommuneId() {
        return communeId;
    }

    public void setCommuneId(Long communeId) {
        this.communeId = communeId;
    }
}

