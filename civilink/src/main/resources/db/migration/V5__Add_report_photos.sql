-- Flyway Migration: Add photos attached to reports (citizen uploads)
-- Version: 5
-- Created: 2026-04-03

CREATE TABLE IF NOT EXISTS report_photos (
    report_id BIGINT NOT NULL,
    photo_url VARCHAR(1000) NOT NULL
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_report_photos_report') THEN
        ALTER TABLE report_photos
            ADD CONSTRAINT fk_report_photos_report
            FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE;
    END IF;
END $$;

