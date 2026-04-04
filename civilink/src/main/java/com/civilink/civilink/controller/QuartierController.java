package com.civilink.civilink.controller;

import com.civilink.civilink.dto.quartier.QuartierResponse;
import com.civilink.civilink.entity.Quartier;
import com.civilink.civilink.service.QuartierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/civilink/quartiers")
public class QuartierController {

    @Autowired
    private QuartierService quartierService;

    @GetMapping
    public List<QuartierResponse> getAllQuartiers() {
        return quartierService.getAllQuartiers().stream()
            .map(this::toResponse)
            .toList();
    }

    @GetMapping("/{id}")
    public QuartierResponse getQuartierById(@PathVariable Long id) {
        return toResponse(quartierService.getQuartierById(id));
    }

    @GetMapping("/commune/{communeId}")
    public List<QuartierResponse> getQuartiersByCommune(@PathVariable Long communeId) {
        return quartierService.getQuartiersByCommune(communeId).stream()
            .map(this::toResponse)
            .toList();
    }

    @PostMapping
    public Quartier createQuartier(@RequestBody Quartier quartier) {
        return quartierService.saveQuartier(quartier);
    }

    private QuartierResponse toResponse(Quartier quartier) {
        if (quartier == null) {
            return null;
        }
        Long communeId = quartier.getCommune() == null ? null : quartier.getCommune().getId();
        return new QuartierResponse(quartier.getId(), quartier.getName(), communeId);
    }
}
