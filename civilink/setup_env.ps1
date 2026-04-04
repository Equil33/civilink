# Environment setup for Civilink API

# Database configuration
$env:DB_URL = "jdbc:postgresql://localhost:5432/civilink"
$env:DB_USERNAME = "postgres"
$env:DB_PASSWORD = "your_postgres_password_here"

# Security configuration
$env:TOKEN_SECRET = "your_secure_token_secret_here"

# CORS configuration (optional)
$env:CORS_ALLOWED_ORIGINS = "http://localhost:3000"

Write-Host "Environment variables set:"
Write-Host "DB_URL=$env:DB_URL"
Write-Host "DB_USERNAME=$env:DB_USERNAME"
Write-Host "DB_PASSWORD=$env:DB_PASSWORD"
Write-Host "TOKEN_SECRET=$env:TOKEN_SECRET"
Write-Host "CORS_ALLOWED_ORIGINS=$env:CORS_ALLOWED_ORIGINS"