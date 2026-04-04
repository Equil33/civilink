package com.civilink.civilink.service.impl;

import com.civilink.civilink.entity.Institution;
import com.civilink.civilink.repository.InstitutionRepository;
import com.civilink.civilink.service.InstitutionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class InstitutionServiceImpl implements InstitutionService {

    @Autowired
    private InstitutionRepository institutionRepository;

    @Override
    public List<Institution> getAllInstitutions() {
        return institutionRepository.findAll();
    }

    @Override
    public Institution getInstitutionById(Long id) {
        return institutionRepository.findById(id).orElse(null);
    }

    @Override
    public List<Institution> getInstitutionsByCommune(Long communeId) {
        return institutionRepository.findByCommuneId(communeId);
    }

    @Override
    public List<Institution> getInstitutionsByCommuneAndType(Long communeId, String type) {
        return institutionRepository.findByCommuneIdAndType(communeId, type);
    }

    @Override
    public Institution saveInstitution(Institution institution) {
        return institutionRepository.save(institution);
    }
}