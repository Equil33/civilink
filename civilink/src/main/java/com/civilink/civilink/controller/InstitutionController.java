package com.civilink.civilink.controller;

import com.civilink.civilink.entity.Institution;
import com.civilink.civilink.service.InstitutionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/institutions")
public class InstitutionController {

    @Autowired
    private InstitutionService institutionService;

    @GetMapping
    public List<Institution> getAllInstitutions() {
        return institutionService.getAllInstitutions();
    }

    @GetMapping("/{id}")
    public Institution getInstitutionById(@PathVariable Long id) {
        return institutionService.getInstitutionById(id);
    }

    @GetMapping("/commune/{communeId}")
    public List<Institution> getInstitutionsByCommune(@PathVariable Long communeId) {
        return institutionService.getInstitutionsByCommune(communeId);
    }

    @GetMapping("/commune/{communeId}/type/{type}")
    public List<Institution> getInstitutionsByCommuneAndType(@PathVariable Long communeId, @PathVariable String type) {
        return institutionService.getInstitutionsByCommuneAndType(communeId, type);
    }

    @PostMapping
    public Institution createInstitution(@RequestBody Institution institution) {
        return institutionService.saveInstitution(institution);
    }
}