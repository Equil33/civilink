-- Flyway Migration: Initial Schema Creation
-- Version: 1
-- Created: 2026-03-30

-- Create app_users table
CREATE TABLE IF NOT EXISTS app_users (
    id BIGSERIAL PRIMARY KEY,
    role VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    nom VARCHAR(100),
    prenoms VARCHAR(100),
    id_type VARCHAR(50),
    id_number VARCHAR(50),
    id_expiration_date VARCHAR(50),
    org_type VARCHAR(50),
    service_card_number VARCHAR(50),
    commune VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create communes table
CREATE TABLE IF NOT EXISTS communes (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    code VARCHAR(50) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create quartiers table
CREATE TABLE IF NOT EXISTS quartiers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    commune_id BIGINT NOT NULL,
    code VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (commune_id) REFERENCES communes(id) ON DELETE CASCADE
);

-- Create institutions table
CREATE TABLE IF NOT EXISTS institutions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    contact_email VARCHAR(255),
    phone VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create reports table
CREATE TABLE IF NOT EXISTS reports (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description VARCHAR(4000) NOT NULL,
    category VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    quartier_id BIGINT,
    commune_id BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quartier_id) REFERENCES quartiers(id) ON DELETE SET NULL,
    FOREIGN KEY (commune_id) REFERENCES communes(id) ON DELETE SET NULL
);

-- Create report_institutions join table
CREATE TABLE IF NOT EXISTS report_institutions (
    report_id BIGINT NOT NULL,
    institution_id BIGINT NOT NULL,
    PRIMARY KEY (report_id, institution_id),
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
    FOREIGN KEY (institution_id) REFERENCES institutions(id) ON DELETE CASCADE
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_app_users_email ON app_users(email);
CREATE INDEX IF NOT EXISTS idx_app_users_role ON app_users(role);
CREATE INDEX IF NOT EXISTS idx_quartiers_commune ON quartiers(commune_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_category ON reports(category);
