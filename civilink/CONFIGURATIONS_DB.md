# Configuration H2 Persistent - Optionnel

Si vous voulez que les données persistent entre les redémarrages (développement local) :

## Option 1 : H2 avec fichier (Recommandé pour développement)

Dans `src/main/resources/application.properties`, remplacez :

```properties
# De ceci (données perdues au redémarrage):
spring.datasource.url=jdbc:h2:mem:testdb

# À ceci (données persistentes) :
spring.datasource.url=jdbc:h2:file:./data/civilink_db;AUTO_SERVER=TRUE
```

Puis redémarrez l'application. Les données seront sauvegardées dans `./data/civilink_db.mv.db`

## Option 2 : Retour à PostgreSQL (Recommandé pour production)

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/civilink
spring.datasource.username=postgres
spring.datasource.password=votre_mot_de_passe
spring.datasource.driver-class-name=org.postgresql.Driver

spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration

spring.jpa.hibernate.ddl-auto=validate
```

Et dans PowerShell (avant de démarrer l'app) :
```powershell
$env:DB_URL = "jdbc:postgresql://localhost:5432/civilink"
$env:DB_USERNAME = "postgres"
$env:DB_PASSWORD = "votre_mot_de_passe_postgres"
$env:TOKEN_SECRET = "your_secret_key_here"
```

## Accès à la base de données

- Console H2 : http://localhost:8081/h2-console
- Endpoint API : http://localhost:8081/api/civilink/auth/users
- Vérifier les logs Spring Boot pour confirmer que les données sont sauvegardées
