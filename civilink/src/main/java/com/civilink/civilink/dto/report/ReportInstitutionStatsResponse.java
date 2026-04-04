package com.civilink.civilink.dto.report;

import java.util.LinkedHashMap;
import java.util.Map;

public class ReportInstitutionStatsResponse {

    private long total;
    private Map<String, Long> byStatus = new LinkedHashMap<>();
    private Map<String, Long> byCategory = new LinkedHashMap<>();

    public long getTotal() {
        return total;
    }

    public void setTotal(long total) {
        this.total = total;
    }

    public Map<String, Long> getByStatus() {
        return byStatus;
    }

    public void setByStatus(Map<String, Long> byStatus) {
        this.byStatus = byStatus;
    }

    public Map<String, Long> getByCategory() {
        return byCategory;
    }

    public void setByCategory(Map<String, Long> byCategory) {
        this.byCategory = byCategory;
    }
}
