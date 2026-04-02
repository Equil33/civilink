-- Flyway Migration: Align DB schema with JPA entities
-- Version: 3
-- Created: 2026-04-02

-- Ensure required columns on communes
ALTER TABLE communes
    ADD COLUMN IF NOT EXISTS prefecture VARCHAR(255);

UPDATE communes
SET prefecture = 'Unknown'
WHERE prefecture IS NULL;

ALTER TABLE communes
    ALTER COLUMN prefecture SET NOT NULL;

-- Institutions: add missing columns to match com.civilink.civilink.entity.Institution
ALTER TABLE institutions
    ADD COLUMN IF NOT EXISTS type VARCHAR(50),
    ADD COLUMN IF NOT EXISTS address VARCHAR(255),
    ADD COLUMN IF NOT EXISTS email VARCHAR(255),
    ADD COLUMN IF NOT EXISTS commune_id BIGINT;

UPDATE institutions
SET type = 'unknown'
WHERE type IS NULL;

ALTER TABLE institutions
    ALTER COLUMN type SET NOT NULL;

-- Create a fallback commune and ensure institutions.commune_id is NOT NULL and FK'd
DO $$
DECLARE
    unknown_commune_id BIGINT;
BEGIN
    INSERT INTO communes (name, prefecture)
    VALUES ('Unknown', 'Unknown')
    ON CONFLICT (name) DO NOTHING;

    SELECT id INTO unknown_commune_id
    FROM communes
    WHERE name = 'Unknown'
    LIMIT 1;

    IF unknown_commune_id IS NOT NULL THEN
        EXECUTE format('ALTER TABLE institutions ALTER COLUMN commune_id SET DEFAULT %s', unknown_commune_id);
        EXECUTE format('UPDATE institutions SET commune_id = %s WHERE commune_id IS NULL', unknown_commune_id);
        ALTER TABLE institutions ALTER COLUMN commune_id SET NOT NULL;
        ALTER TABLE institutions ALTER COLUMN commune_id DROP DEFAULT;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_institutions_commune'
    ) THEN
        ALTER TABLE institutions
            ADD CONSTRAINT fk_institutions_commune
            FOREIGN KEY (commune_id) REFERENCES communes(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Reports: add missing columns to match com.civilink.civilink.entity.Report
ALTER TABLE reports
    ADD COLUMN IF NOT EXISTS address VARCHAR(255),
    ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS date VARCHAR(50),
    ADD COLUMN IF NOT EXISTS votes INTEGER,
    ADD COLUMN IF NOT EXISTS reporter_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS reporter_type VARCHAR(255);

UPDATE reports SET address = '' WHERE address IS NULL;
UPDATE reports SET date = '' WHERE date IS NULL;
UPDATE reports SET votes = 0 WHERE votes IS NULL;
UPDATE reports SET reporter_id = '' WHERE reporter_id IS NULL;
UPDATE reports SET reporter_type = '' WHERE reporter_type IS NULL;

ALTER TABLE reports
    ALTER COLUMN address SET NOT NULL,
    ALTER COLUMN date SET NOT NULL,
    ALTER COLUMN votes SET NOT NULL,
    ALTER COLUMN reporter_id SET NOT NULL,
    ALTER COLUMN reporter_type SET NOT NULL;

-- Element collections for Report.nearbyOrganisations and Report.resolutionPhotos
CREATE TABLE IF NOT EXISTS report_nearby_organisations (
    report_id BIGINT NOT NULL,
    organisation_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS report_resolution_photos (
    report_id BIGINT NOT NULL,
    photo_url VARCHAR(1000) NOT NULL
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_report_nearby_org_report') THEN
        ALTER TABLE report_nearby_organisations
            ADD CONSTRAINT fk_report_nearby_org_report
            FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_report_resolution_photos_report') THEN
        ALTER TABLE report_resolution_photos
            ADD CONSTRAINT fk_report_resolution_photos_report
            FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE;
    END IF;
END $$;

