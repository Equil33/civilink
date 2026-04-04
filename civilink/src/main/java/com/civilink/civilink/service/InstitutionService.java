package com.civilink.civilink.service;

import com.civilink.civilink.entity.Institution;

import java.util.List;

public interface InstitutionService {
    List<Institution> getAllInstitutions();
    Institution getInstitutionById(Long id);
    List<Institution> getInstitutionsByCommune(Long communeId);
    List<Institution> getInstitutionsByCommuneAndType(Long communeId, String type);
    Institution saveInstitution(Institution institution);
}