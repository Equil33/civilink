package com.civilink.civilink.service;

import com.civilink.civilink.entity.Quartier;

import java.util.List;

public interface QuartierService {
    List<Quartier> getAllQuartiers();
    Quartier getQuartierById(Long id);
    List<Quartier> getQuartiersByCommune(Long communeId);
    Quartier saveQuartier(Quartier quartier);
}