# Mon Quartier Vigilant - Flutter

Projet converti en Flutter (React/Vite retire).

## Prerequis
- Flutter 3.41+

## Lancer en local (Web)
```bash
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 7357
```

Puis ouvrir: http://127.0.0.1:7357

## Fonctionnalites
- Auth locale (session sauvegardee)
- Creation de signalement
- Liste/filtrage des signalements
- Votes et mise a jour de statut
- Dashboard citoyen
- Espaces Organisation et Admin

Les donnees sont persistantes en local via `shared_preferences`.

## Connexion à PostgreSQL (API Spring Boot)
L'application Flutter ne doit pas se connecter directement à PostgreSQL.
Une API Spring Boot est incluse dans `../civilink_api/civilink`.

### 1) Demarrer l'API Spring Boot

Configuration de l'environnement (Linux/Mac):
```bash
export DB_URL=jdbc:postgresql://localhost:5432/civilink_bd
export DB_USERNAME=postgres
export DB_PASSWORD=postgres
export TOKEN_SECRET=your-secret-key-here-change-in-production
cd ../civilink_api/civilink
./mvnw spring-boot:run
```

Configuration de l'environnement (Windows PowerShell):
```powershell
$env:DB_URL='jdbc:postgresql://localhost:5432/civilink_bd'
$env:DB_USERNAME='postgres'
$env:DB_PASSWORD='postgres'
$env:TOKEN_SECRET='your-secret-key-here-change-in-production'
cd ../civilink_api/civilink
.\mvnw.cmd spring-boot:run
```

API disponible sur: `http://127.0.0.1:8080`

### 2) Demarrer Flutter connecte a l'API
```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

Le frontend appelle automatiquement `http://127.0.0.1:8080/api/civilink/...`.

**Important**: 
- Assurez-vous que PostgreSQL est en cours d'exécution
- Les variables d'environnement TOKEN_SECRET, DB_USERNAME, et DB_PASSWORD DOIVENT être définies en production
- Utilisez des secrets forts pour TOKEN_SECRET en production
