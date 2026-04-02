package com.civilink.civilink.service.impl;

import com.civilink.civilink.entity.Commune;
import com.civilink.civilink.entity.Institution;
import com.civilink.civilink.entity.Quartier;
import com.civilink.civilink.entity.Report;
import com.civilink.civilink.service.InstitutionService;
import com.civilink.civilink.service.ReportRoutingService;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ReportRoutingServiceImpl implements ReportRoutingService {

    @Autowired
    private InstitutionService institutionService;

    @Override
    public Set<Institution> determineTargetInstitutions(Report report) {
        Set<Institution> targets = new HashSet<>();

        // If quartier is set, add the commune's mairie
        if (report.getQuartier() != null) {
            targets.addAll(getInstitutionsForQuartier(report.getQuartier()));
        }

        targets.addAll(getInstitutionsForCategory(report.getCategory(), report.getCommune()));

        return targets;
    }

    @Override
    public Set<Institution> getInstitutionsForQuartier(Quartier quartier) {
        Set<Institution> targets = new HashSet<>();
        List<Institution> mairies = institutionService.getInstitutionsByCommuneAndType(
            quartier.getCommune().getId(), "mairie");
        targets.addAll(mairies);
        return targets;
    }

    @Override
    public Set<Institution> getInstitutionsForCategory(String category, Commune commune) {
        Set<Institution> targets = new HashSet<>();

        String normalized = normalize(category);
        if (normalized.contains("accident")) {
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "mairie"));
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "pompiers"));
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "gendarmerie"));
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "police"));
        } else if (normalized.contains("sante")) {
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "hopital_public"));
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "hopital"));
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "clinique"));
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "cms"));
        } else if (normalized.contains("securite")) {
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "gendarmerie"));
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "police"));
        } else if (normalized.contains("voirie")) {
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "voirie"));
        } else if (normalized.contains("incend")) {
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "pompiers"));
        } else if (normalized.contains("inond")) {
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "mairie"));
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "pompiers"));
        } else if (normalized.contains("dechet") || normalized.contains("degat")) {
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "mairie"));
            if (normalized.contains("dechet")) {
                targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "voirie"));
            }
        } else {
            targets.addAll(institutionService.getInstitutionsByCommuneAndType(commune.getId(), "mairie"));
        }

        return targets;
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        return value.trim().toLowerCase(Locale.ROOT);
    }
}
