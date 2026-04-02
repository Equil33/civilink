# PowerShell script to set environment variables for PostgreSQL

# Database configuration
$env:DB_URL = "jdbc:postgresql://localhost:5432/civilink_bd"
$env:DB_USERNAME = "postgres"
$env:DB_PASSWORD = "votre_mot_de_passe_postgres"  # Change this to your actual password

# Security configuration
$env:TOKEN_SECRET = "MySecureTokenSecret1234567890abcdefghijklmnop"

# CORS configuration (optional)
$env:CORS_ALLOWED_ORIGINS = "http://localhost:3000"

Write-Host "========================================" -ForegroundColor Green
Write-Host "PostgreSQL Environment Variables Set" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "DB_URL: $env:DB_URL"
Write-Host "DB_USERNAME: $env:DB_USERNAME"
Write-Host "DB_PASSWORD: $env:DB_PASSWORD"
Write-Host "TOKEN_SECRET: $env:TOKEN_SECRET"
Write-Host "CORS_ALLOWED_ORIGINS: $env:CORS_ALLOWED_ORIGINS"
Write-Host ""
Write-Host "IMPORTANT: Change 'votre_mot_de_passe_postgres' to your actual PostgreSQL password" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Green
