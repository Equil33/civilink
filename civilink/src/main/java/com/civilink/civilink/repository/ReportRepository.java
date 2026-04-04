package com.civilink.civilink.repository;

import com.civilink.civilink.entity.Report;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReportRepository extends JpaRepository<Report, Long> {

    List<Report> findAllByOrderByCreatedAtDesc();

    List<Report> findByReporterIdOrderByCreatedAtDesc(String reporterId);
}

