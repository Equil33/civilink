# Problème de données utilisateurs non persistantes

## Diagnostic

Le problème que vous rencontrez (les utilisateurs enregistrés ne s'affichent pas dans la base de données) est dû à la configuration actuelle qui utilise **H2 en mémoire (`jdbc:h2:mem:testdb`)**.

### Pourquoi les données disparaissent ?

1. **H2 en mémoire** : Chaque redémarrage de l'application réinitialise la base de données
2. **Pas de persistance** : Les données n'existent que pendant que l'app tourne

## Solutions pour Vérifier les Données

### Solution 1 : Console H2 (Immediate)
Pendant que l'app tourne :
1. Allez à : **http://localhost:8081/h2-console**
2. JDBC URL : `jdbc:h2:mem:testdb`
3. Username : `sa`
4. Pas de password
5. Cliquez "Connect"

### Solution 2 : Endpoint API (Immediate) 
Appelez : **GET http://localhost:8081/api/civilink/auth/users**

Réponse :
```json
{
  "total": 2,
  "users": [
    {
      "id": 1,
      "email": "user@example.com",
      "nom": "Dupont",
      "prenoms": "Jean",
      "role": "citoyen"
    }
  ]
}
```

### Solution 3 : Utiliser H2 basé sur fichier (Recommandée pour le développement)
```properties
spring.datasource.url=jdbc:h2:file:./data/civilink_db
spring.datasource.username=sa
spring.datasource.password=
```
Les données seront sauvegardées dans le dossier `data/`

### Solution 4 : Utiliser PostgreSQL (Recommandée pour la production)
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/civilink
spring.datasource.username=postgres
spring.datasource.password=votre_mot_de_passe
spring.flyway.enabled=true
spring.jpa.hibernate.ddl-auto=validate
```

## Actions Effectuées

✅ Console H2 activée sur http://localhost:8081/h2-console
✅ Endpoint GET /api/civilink/auth/users créé pour lister les utilisateurs
✅ Port changé à 8081 (pour éviter les conflits)

## Prochaines Étapes

Redémarrez l'application et testez :
1. Inscrivez un utilisateur
2. Consultez les données via la console H2 ou l'endpoint API
3. Decidez si vous voulez passer à H2 fichier ou PostgreSQL
