package com.civilink.civilink.entity;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "communes")
public class Commune {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    @Column(nullable = false)
    private String prefecture; // Golfe or Agoè-Nyivé

    @OneToMany(mappedBy = "commune", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Quartier> quartiers;

    @OneToMany(mappedBy = "commune", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Institution> institutions;

    // Constructors
    public Commune() {}

    public Commune(String name, String prefecture) {
        this.name = name;
        this.prefecture = prefecture;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPrefecture() { return prefecture; }
    public void setPrefecture(String prefecture) { this.prefecture = prefecture; }

    public List<Quartier> getQuartiers() { return quartiers; }
    public void setQuartiers(List<Quartier> quartiers) { this.quartiers = quartiers; }

    public List<Institution> getInstitutions() { return institutions; }
    public void setInstitutions(List<Institution> institutions) { this.institutions = institutions; }
}