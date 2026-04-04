package com.civilink.civilink.repository;

import com.civilink.civilink.entity.Commune;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CommuneRepository extends JpaRepository<Commune, Long> {
    Commune findByName(String name);
}