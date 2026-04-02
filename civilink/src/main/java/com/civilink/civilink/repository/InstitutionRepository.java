package com.civilink.civilink.repository;

import com.civilink.civilink.entity.Institution;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InstitutionRepository extends JpaRepository<Institution, Long> {
    List<Institution> findByCommuneId(Long communeId);
    List<Institution> findByCommuneIdAndType(Long communeId, String type);
}