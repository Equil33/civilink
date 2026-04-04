# ✅ Configuration PostgreSQL - Prêt pour Démarrage

Votre application Civilink a été configurée pour utiliser PostgreSQL avec la base de données **civilink_bd**.

## 🚀 Étapes pour Démarrer

### 1. Assurez-vous que PostgreSQL est en cours d'exécution
- PostgreSQL doit être sur `localhost:5432`
- Base de données: `civilink_bd`
- Utilisateur: `postgres`

### 2. Ouvrez PowerShell et allez dans le dossier du projet
```powershell
cd d:\BRICE\iiiii\civilink_api\civilink
```

### 3. Définissez les variables d'environnement

**Option A: Exécuter le script PowerShell**
```powershell
.\setup_postgres.ps1
```

**Option B: Définir manuellement**
```powershell
$env:DB_URL = "jdbc:postgresql://localhost:5432/civilink_bd"
$env:DB_USERNAME = "postgres"
$env:DB_PASSWORD = "votre_mot_de_passe_postgres"  # ← REMPLACEZ-MOI
$env:TOKEN_SECRET = "MySecureTokenSecret1234567890abcdefghijklmnop"
```

### 4. Démarrez l'application
```powershell
.\mvnw.cmd spring-boot:run
```

## 📊 Tests des Endpoints

### Inscrire un citoyen
```bash
POST http://localhost:8081/api/civilink/auth/register/citoyen
Content-Type: application/json

{
  "nom": "Dupont",
  "prenoms": "Jean",
  "idType": "CNI",
  "idNumber": "123456789",
  "idExpirationDate": "2030-12-31",
  "phone": "+243975123456",
  "email": "jean.dupont@example.com",
  "password": "Password123!"
}
```

### Voir tous les utilisateurs
```bash
GET http://localhost:8081/api/civilink/auth/users
```

## 🔧 Paramètres Importants

| Paramètre | Valeur |
|-----------|--------|
| DB URL | jdbc:postgresql://localhost:5432/civilink_bd |
| DB Username | postgres |
| DB Password | Votre mot de passe PostgreSQL |
| Port API | 8081 |
| TOKEN_SECRET | MySecureTokenSecret1234567890abcdefghijklmnop |

## 📝 Variables d'Environnement à Personnaliser

Ouvrez `setup_postgres.ps1` et changez :
- `DB_PASSWORD` : Votre mot de passe PostgreSQL réel
- `TOKEN_SECRET` : Générez une clé sécurisée pour la production

## 🛠️ Troubleshooting

### Erreur: "FATAL: password authentication failed"
→ Vérifiez que `DB_PASSWORD` est correct et correspond à votre mot de passe PostgreSQL

### Erreur: "database "civilink_bd" does not exist"
→ Créez la base de données :
```sql
CREATE DATABASE civilink_bd;
```

### Erreur: "Connection refused"
→ Vérifiez que PostgreSQL est en cours d'exécution sur localhost:5432

## ✨ Prochaines Étapes

Les migrations Flyway vont automatiquement :
1. Créer les tables (si elles n'existent pas)
2. Valider le schéma
3. Persister les données

Votre application est maintenant prête ! 🎉
