package com.civilink.civilink.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "quartiers")
public class Quartier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "commune_id", nullable = false)
    private Commune commune;

    // Constructors
    public Quartier() {}

    public Quartier(String name, Commune commune) {
        this.name = name;
        this.commune = commune;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Commune getCommune() { return commune; }
    public void setCommune(Commune commune) { this.commune = commune; }
}