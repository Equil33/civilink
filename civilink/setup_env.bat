@echo off
REM Environment setup for Civilink API

REM Database configuration
set DB_URL=jdbc:postgresql://localhost:5432/civilink
set DB_USERNAME=postgres
set DB_PASSWORD=your_postgres_password_here

REM Security configuration
set TOKEN_SECRET=your_secure_token_secret_here

REM CORS configuration (optional)
set CORS_ALLOWED_ORIGINS=http://localhost:3000

echo Environment variables set:
echo DB_URL=%DB_URL%
echo DB_USERNAME=%DB_USERNAME%
echo DB_PASSWORD=%DB_PASSWORD%
echo TOKEN_SECRET=%TOKEN_SECRET%
echo CORS_ALLOWED_ORIGINS=%CORS_ALLOWED_ORIGINS%