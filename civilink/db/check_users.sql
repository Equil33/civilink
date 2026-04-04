-- Script pour vérifier les utilisateurs dans la base de données Civilink
-- Exécutez ce script dans votre base PostgreSQL

-- 1. Compter le nombre total d'utilisateurs
SELECT COUNT(*) as total_users FROM app_users;

-- 2. Lister tous les utilisateurs (sans les mots de passe)
SELECT
    id,
    email,
    role,
    display_name,
    phone,
    created_at,
    CASE
        WHEN role = 'citoyen' THEN 'Citoyen'
        WHEN role = 'organisation' THEN org_type || ' (' || commune || ')'
        ELSE role
    END as details
FROM app_users
ORDER BY created_at DESC;

-- 3. Vérifier s'il y a des utilisateurs citoyens
SELECT COUNT(*) as citoyens FROM app_users WHERE role = 'citoyen';

-- 4. Vérifier s'il y a des utilisateurs organisations
SELECT COUNT(*) as organisations FROM app_users WHERE role = 'organisation';

-- 5. Détails des organisations
SELECT
    email,
    org_type,
    commune,
    display_name
FROM app_users
WHERE role = 'organisation'
ORDER BY org_type, commune;