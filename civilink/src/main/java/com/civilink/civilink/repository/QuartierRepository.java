package com.civilink.civilink.repository;

import com.civilink.civilink.entity.Quartier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuartierRepository extends JpaRepository<Quartier, Long> {
    List<Quartier> findByCommuneId(Long communeId);
    Quartier findByNameAndCommuneId(String name, Long communeId);
}