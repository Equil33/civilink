package com.civilink.civilink.controller;

import com.civilink.civilink.dto.commune.CommuneResponse;
import com.civilink.civilink.entity.Commune;
import com.civilink.civilink.service.CommuneService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/civilink/communes")
public class CommuneController {

    @Autowired
    private CommuneService communeService;

    @GetMapping
    public List<CommuneResponse> getAllCommunes() {
        return communeService.getAllCommunes().stream()
            .map(this::toResponse)
            .toList();
    }

    @GetMapping("/{id}")
    public CommuneResponse getCommuneById(@PathVariable Long id) {
        return toResponse(communeService.getCommuneById(id));
    }

    @PostMapping
    public Commune createCommune(@RequestBody Commune commune) {
        return communeService.saveCommune(commune);
    }

    private CommuneResponse toResponse(Commune commune) {
        if (commune == null) {
            return null;
        }
        return new CommuneResponse(commune.getId(), commune.getName(), commune.getPrefecture());
    }
}
