@echo off
REM Environment setup for Civilink API with PostgreSQL

REM Database configuration
set DB_URL=jdbc:postgresql://localhost:5432/civilink_bd
set DB_USERNAME=postgres
set DB_PASSWORD=votre_mot_de_passe_postgres

REM Security configuration
set TOKEN_SECRET=MySecureTokenSecret1234567890abcdefghijklmnop

REM CORS configuration (optional)
set CORS_ALLOWED_ORIGINS=http://localhost:3000

echo.
echo ========================================
echo Environment variables for PostgreSQL:
echo ========================================
echo DB_URL=%DB_URL%
echo DB_USERNAME=%DB_USERNAME%
echo DB_PASSWORD=%DB_PASSWORD%
echo TOKEN_SECRET=%TOKEN_SECRET%
echo CORS_ALLOWED_ORIGINS=%CORS_ALLOWED_ORIGINS%
echo.
echo Note: Change votre_mot_de_passe_postgres to your actual PostgreSQL password
echo ========================================
echo.