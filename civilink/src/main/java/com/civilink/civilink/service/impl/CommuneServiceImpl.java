package com.civilink.civilink.service.impl;

import com.civilink.civilink.entity.Commune;
import com.civilink.civilink.repository.CommuneRepository;
import com.civilink.civilink.service.CommuneService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CommuneServiceImpl implements CommuneService {

    @Autowired
    private CommuneRepository communeRepository;

    @Override
    public List<Commune> getAllCommunes() {
        return communeRepository.findAll();
    }

    @Override
    public Commune getCommuneById(Long id) {
        return communeRepository.findById(id).orElse(null);
    }

    @Override
    public Commune getCommuneByName(String name) {
        return communeRepository.findByName(name);
    }

    @Override
    public Commune saveCommune(Commune commune) {
        return communeRepository.save(commune);
    }
}