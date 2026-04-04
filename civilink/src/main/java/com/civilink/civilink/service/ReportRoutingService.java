package com.civilink.civilink.service;

import com.civilink.civilink.entity.Commune;
import com.civilink.civilink.entity.Institution;
import com.civilink.civilink.entity.Quartier;
import com.civilink.civilink.entity.Report;

import java.util.Set;

public interface ReportRoutingService {
    Set<Institution> determineTargetInstitutions(Report report);
    Set<Institution> getInstitutionsForQuartier(Quartier quartier);
    Set<Institution> getInstitutionsForCategory(String category, Commune commune);
}