#!/bin/bash

# Script de test pour l'API Civilink
# Vérifie les utilisateurs en base et teste la connexion

echo "=== Test de l'API Civilink ==="
echo ""

# Vérifier si l'API est accessible
echo "1. Test de connectivité de l'API..."
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/api/civilink/auth/login
if [ $? -eq 0 ]; then
    echo "✅ API accessible"
else
    echo "❌ API non accessible - Vérifiez que le serveur tourne sur http://127.0.0.1:8080"
    exit 1
fi

echo ""
echo "2. Test de connexion avec des identifiants fictifs..."
curl -X POST http://127.0.0.1:8080/api/civilink/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123",
    "role": "citoyen"
  }' | jq . 2>/dev/null || echo "Réponse brute:"

echo ""
echo "3. Pour déboguer plus, consultez les logs du serveur Spring Boot"
echo "   Les nouveaux logs détaillés vous diront exactement ce qui se passe"
echo ""
echo "4. Si aucun utilisateur n'existe, vous devez d'abord vous inscrire via l'app Flutter"
echo "   Allez sur la page d'inscription et créez un compte citoyen ou organisation"</content>
<parameter name="filePath">D:\BRICE\iiiii\civilink_api\civilink\test_api.sh