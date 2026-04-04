package com.civilink.civilink.controller;

import com.civilink.civilink.dto.appuser.AppUserResponse;
import com.civilink.civilink.entity.AppUser;
import com.civilink.civilink.repository.AppUserRepository;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/app-users")
public class AppUserController {

    private final AppUserRepository appUserRepository;

    public AppUserController(AppUserRepository appUserRepository) {
        this.appUserRepository = appUserRepository;
    }

    @GetMapping
    public List<AppUserResponse> getAllUsers() {
        return appUserRepository.findAll()
            .stream()
            .map(this::toResponse)
            .toList();
    }

    @GetMapping("/{id}")
    public AppUserResponse getUserById(@PathVariable Long id) {
        return appUserRepository.findById(id)
            .map(this::toResponse)
            .orElse(null);
    }

    private AppUserResponse toResponse(AppUser user) {
        if (user == null) {
            return null;
        }
        AppUserResponse response = new AppUserResponse();
        response.setId(user.getId());
        response.setRole(user.getRole());
        response.setEmail(user.getEmail());
        response.setPhone(user.getPhone());
        response.setDisplayName(user.getDisplayName());
        response.setNom(user.getNom());
        response.setPrenoms(user.getPrenoms());
        response.setIdType(user.getIdType());
        response.setIdNumber(user.getIdNumber());
        response.setIdExpirationDate(user.getIdExpirationDate());
        response.setOrgType(user.getOrgType());
        response.setServiceCardNumber(user.getServiceCardNumber());
        response.setCommune(user.getCommune());
        return response;
    }
}
