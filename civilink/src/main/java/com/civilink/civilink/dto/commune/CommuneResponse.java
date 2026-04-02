package com.civilink.civilink.dto.commune;

public class CommuneResponse {

    private Long id;
    private String name;
    private String prefecture;

    public CommuneResponse() {}

    public CommuneResponse(Long id, String name, String prefecture) {
        this.id = id;
        this.name = name;
        this.prefecture = prefecture;
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

    public String getPrefecture() {
        return prefecture;
    }

    public void setPrefecture(String prefecture) {
        this.prefecture = prefecture;
    }
}

