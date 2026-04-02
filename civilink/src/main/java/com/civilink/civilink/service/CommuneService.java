package com.civilink.civilink.service;

import com.civilink.civilink.entity.Commune;

import java.util.List;

public interface CommuneService {
    List<Commune> getAllCommunes();
    Commune getCommuneById(Long id);
    Commune getCommuneByName(String name);
    Commune saveCommune(Commune commune);
}