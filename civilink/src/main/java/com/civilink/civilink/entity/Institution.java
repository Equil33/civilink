package com.civilink.civilink.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "institutions")
public class Institution {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String type; // mairie, gendarmerie, hopital, cms, pompiers, voirie

    @Column(nullable = false)
    private String name;

    private String address;
    private String phone;
    private String email;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "commune_id", nullable = false)
    private Commune commune;

    // Constructors
    public Institution() {}

    public Institution(String type, String name, Commune commune) {
        this.type = type;
        this.name = name;
        this.commune = commune;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Commune getCommune() { return commune; }
    public void setCommune(Commune commune) { this.commune = commune; }
}