# Civilink API (Spring Boot)

API backend pour le projet Flutter `mon-quartier-vigilant-main`.

## Stack
- Java 17+
- Spring Boot 3.3.8
- Spring Web
- Spring Data JPA
- Validation
- PostgreSQL

## Architecture
Packages principaux:
- `com.civilink.civilink.config`
- `com.civilink.civilink.controller`
- `com.civilink.civilink.dto.auth`
- `com.civilink.civilink.dto.report`
- `com.civilink.civilink.entity`
- `com.civilink.civilink.repository`
- `com.civilink.civilink.service`
- `com.civilink.civilink.service.impl`
- `com.civilink.civilink.exception`

## Configuration
Le projet lit les variables d'environnement suivantes:
- `DB_URL` (defaut: `jdbc:postgresql://localhost:5432/civilink_bd`)
- `DB_USERNAME` (defaut: `postgres`)
- `DB_PASSWORD` (defaut: `postgres`)
- `TOKEN_SECRET`
- `ACCESS_TOKEN_EXPIRATION_SECONDS` (defaut: `3600`)
- `REFRESH_TOKEN_EXPIRATION_SECONDS` (defaut: `604800`)

## Lancer l'API
```powershell
cd d:\BRICE\iiiii\civilink_api\civilink
cmd /c mvnw.cmd spring-boot:run
```

API: `http://127.0.0.1:8080`

## Endpoints (compatibles Flutter)
Base path: `/api/civilink`

Auth:
- `POST /auth/register/citoyen`
- `POST /auth/register/organisation`
- `POST /auth/login`
- `POST /auth/token/refresh`

Reports:
- `GET /reports`
- `GET /reports/mine`
- `POST /reports`
- `PATCH /reports/{id}/status`
- `PATCH /reports/{id}/vote`
- `PATCH /reports/{id}`
- `DELETE /reports/{id}`

## Connexion Flutter -> Spring
Depuis ton projet Flutter:
```powershell
cd d:\BRICE\iiiii\mon-quartier-vigilant-main (1)\mon-quartier-vigilant-main
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

Le frontend construit automatiquement: `http://127.0.0.1:8080/api/civilink/...`