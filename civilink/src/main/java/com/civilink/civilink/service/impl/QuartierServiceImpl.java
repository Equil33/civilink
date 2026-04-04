package com.civilink.civilink.service.impl;

import com.civilink.civilink.entity.Quartier;
import com.civilink.civilink.repository.QuartierRepository;
import com.civilink.civilink.service.QuartierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class QuartierServiceImpl implements QuartierService {

    @Autowired
    private QuartierRepository quartierRepository;

    @Override
    public List<Quartier> getAllQuartiers() {
        return quartierRepository.findAll();
    }

    @Override
    public Quartier getQuartierById(Long id) {
        return quartierRepository.findById(id).orElse(null);
    }

    @Override
    public List<Quartier> getQuartiersByCommune(Long communeId) {
        return quartierRepository.findByCommuneId(communeId);
    }

    @Override
    public Quartier saveQuartier(Quartier quartier) {
        return quartierRepository.save(quartier);
    }
}