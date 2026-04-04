-- Manual migration for PostgreSQL
-- Remove org_name and org_responsible from app_users (organisation registration no longer uses them).
ALTER TABLE app_users DROP COLUMN IF EXISTS org_name;
ALTER TABLE app_users DROP COLUMN IF EXISTS org_responsible;
