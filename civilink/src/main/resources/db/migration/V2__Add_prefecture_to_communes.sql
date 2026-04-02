-- Flyway Migration: Add prefecture column to communes
-- Version: 2
-- Created: 2026-04-02

ALTER TABLE communes
    ADD COLUMN IF NOT EXISTS prefecture VARCHAR(255);

UPDATE communes
SET prefecture = 'Unknown'
WHERE prefecture IS NULL;

ALTER TABLE communes
    ALTER COLUMN prefecture SET NOT NULL;

