package com.civilink.civilink.config;

import java.sql.Connection;
import java.sql.DatabaseMetaData;

import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class SchemaFixRunner implements ApplicationRunner {

    private static final Logger logger = LoggerFactory.getLogger(SchemaFixRunner.class);
    private static final String REPORTS_TABLE = "reports";
    private static final String QUARTIER_ID_COLUMN = "quartier_id";
    private static final String QUARTIER_LEGACY_COLUMN = "quartier";
    private static final String COMMUNE_ID_COLUMN = "commune_id";
    private static final String FK_REPORTS_COMMUNE = "fk_reports_commune";

    private final JdbcTemplate jdbcTemplate;
    private final DataSource dataSource;
    private boolean isPostgres;

    public SchemaFixRunner(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.dataSource = dataSource;
        this.isPostgres = detectDatabase();
    }

    private boolean detectDatabase() {
        try (Connection conn = dataSource.getConnection()) {
            DatabaseMetaData metaData = conn.getMetaData();
            String databaseProductName = metaData.getDatabaseProductName();
            return databaseProductName != null && databaseProductName.toLowerCase().contains("postgres");
        } catch (Exception e) {
            logger.warn("Could not detect database type, assuming PostgreSQL", e);
            return true;
        }
    }

    @Override
    public void run(ApplicationArguments args) {
        // Only run schema fixes for PostgreSQL
        if (isPostgres) {
            try {
                ensureReportQuartierColumn();
                ensureReportCommuneColumn();
                ensureReportCommuneForeignKey();
            } catch (Exception e) {
                logger.error("Error in schema fix runner", e);
            }
        }
    }

    private void ensureReportQuartierColumn() {
        if (!columnExists(REPORTS_TABLE, QUARTIER_ID_COLUMN)) {
            logger.info("Schema fix: adding reports.quartier_id column");
            try {
                jdbcTemplate.execute("ALTER TABLE reports ADD COLUMN quartier_id BIGINT");
            } catch (DataAccessException ex) {
                logger.warn("Schema fix: column quartier_id already exists or creation failed", ex);
            }
        }

        if (columnExists(REPORTS_TABLE, QUARTIER_LEGACY_COLUMN)) {
            try {
                if (tableExists("quartiers") && columnExists("quartiers", "name")) {
                    jdbcTemplate.execute(
                        "UPDATE reports r SET quartier = q.name " +
                        "FROM quartiers q " +
                        "WHERE r.quartier_id = q.id AND r.quartier IS NULL"
                    );
                }
            } catch (DataAccessException ex) {
                logger.warn("Schema fix: could not update quartier from quartiers table", ex);
            }

            try {
                jdbcTemplate.execute(
                    "UPDATE reports " +
                    "SET quartier_id = CASE " +
                    "  WHEN quartier ~ '^[0-9]+$' THEN quartier::bigint " +
                    "  ELSE quartier_id " +
                    "END " +
                    "WHERE quartier_id IS NULL AND quartier IS NOT NULL"
                );
            } catch (DataAccessException ex) {
                logger.warn("Schema fix: could not cast quartier to bigint", ex);
            }

            try {
                jdbcTemplate.execute("ALTER TABLE reports ALTER COLUMN quartier DROP NOT NULL");
            } catch (DataAccessException ex) {
                logger.warn("Schema fix: could not drop NOT NULL on reports.quartier", ex);
            }
        }

        if (columnExists(REPORTS_TABLE, QUARTIER_ID_COLUMN)) {
            try {
                long nullCount = jdbcTemplate.queryForObject(
                    "SELECT COUNT(*) FROM reports WHERE quartier_id IS NULL",
                    Long.class
                );
                if (nullCount == 0) {
                    try {
                        jdbcTemplate.execute("ALTER TABLE reports ALTER COLUMN quartier_id SET NOT NULL");
                    } catch (DataAccessException ex) {
                        logger.warn("Schema fix: could not set reports.quartier_id NOT NULL", ex);
                    }
                } else {
                    logger.warn("Schema fix: reports.quartier_id has {} NULL values; NOT NULL not enforced", nullCount);
                }
            } catch (DataAccessException ex) {
                logger.warn("Schema fix: could not check NULL values for quartier_id", ex);
            }
        }
    }

    private void ensureReportCommuneColumn() {
        if (!columnExists(REPORTS_TABLE, COMMUNE_ID_COLUMN)) {
            logger.info("Schema fix: adding reports.commune_id column");
            try {
                jdbcTemplate.execute("ALTER TABLE reports ADD COLUMN commune_id BIGINT");
            } catch (DataAccessException ex) {
                logger.warn("Schema fix: column commune_id already exists or creation failed", ex);
            }
        }

        try {
            if (columnExists(REPORTS_TABLE, QUARTIER_ID_COLUMN) && tableExists("quartiers")
                && columnExists("quartiers", "commune_id")) {
                jdbcTemplate.execute(
                    "UPDATE reports r SET commune_id = q.commune_id " +
                    "FROM quartiers q " +
                    "WHERE r.quartier_id = q.id AND r.commune_id IS NULL"
                );
            }
        } catch (DataAccessException ex) {
            logger.warn("Schema fix: could not update commune_id from quartiers table", ex);
        }

        try {
            long nullCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM reports WHERE commune_id IS NULL",
                Long.class
            );

            if (nullCount == 0) {
                try {
                    jdbcTemplate.execute("ALTER TABLE reports ALTER COLUMN commune_id SET NOT NULL");
                } catch (DataAccessException ex) {
                    logger.warn("Schema fix: could not set reports.commune_id NOT NULL", ex);
                }
            } else {
                logger.warn("Schema fix: reports.commune_id has {} NULL values; NOT NULL not enforced", nullCount);
            }
        } catch (DataAccessException ex) {
            logger.warn("Schema fix: could not check NULL values for commune_id", ex);
        }
    }

    private void ensureReportCommuneForeignKey() {
        try {
            if (constraintExists(FK_REPORTS_COMMUNE)) {
                return;
            }
            try {
                jdbcTemplate.execute(
                    "ALTER TABLE reports " +
                    "ADD CONSTRAINT fk_reports_commune " +
                    "FOREIGN KEY (commune_id) REFERENCES communes(id)"
                );
            } catch (DataAccessException ex) {
                logger.warn("Schema fix: could not add fk_reports_commune", ex);
            }
        } catch (DataAccessException ex) {
            logger.warn("Schema fix: could not check constraint existence", ex);
        }
    }

    private boolean columnExists(String tableName, String columnName) {
        try {
            Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.columns " +
                "WHERE table_name = ? AND column_name = ? AND table_schema = current_schema()",
                Integer.class,
                tableName,
                columnName
            );
            return count != null && count > 0;
        } catch (DataAccessException ex) {
            logger.debug("Could not check column existence for {}.{}", tableName, columnName, ex);
            return false;
        }
    }

    private boolean tableExists(String tableName) {
        try {
            Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.tables " +
                "WHERE table_name = ? AND table_schema = current_schema()",
                Integer.class,
                tableName
            );
            return count != null && count > 0;
        } catch (DataAccessException ex) {
            logger.debug("Could not check table existence for {}", tableName, ex);
            return false;
        }
    }

    private boolean constraintExists(String constraintName) {
        try {
            Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM pg_constraint WHERE conname = ?",
                Integer.class,
                constraintName
            );
            return count != null && count > 0;
        } catch (DataAccessException ex) {
            logger.debug("Could not check constraint existence for {}", constraintName, ex);
            return false;
        }
    }
}
