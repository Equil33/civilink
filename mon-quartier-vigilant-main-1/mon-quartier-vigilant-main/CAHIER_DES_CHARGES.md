# Cahier des charges - Mon Quartier Vigilant

Version: 1.0
Date: 19 fevrier 2026
Statut: Projet MVP

## 1. Contexte
Mon Quartier Vigilant est une application web citoyenne qui permet de signaler des problemes urbains (voirie, eclairage, inondation, dechets, autres) et de suivre leur traitement.

Le projet actuel est un MVP frontend (React + TypeScript + Vite) avec des donnees mockees (pas de backend connecte).

## 2. Objectifs
- Faciliter la remontee des incidents urbains par les citoyens.
- Donner de la visibilite sur les signalements en cours et resolus.
- Fournir une vue de pilotage simple pour la mairie (tableau de bord).
- Poser une base technique evolutive vers une version connectee a une API.

## 3. Perimetre fonctionnel (MVP actuel)
### 3.1 Pages disponibles
- `/` (Accueil): hero, categories de signalements, statistiques, signalements recents.
- `/signaler` (Creation de signalement): formulaire avec categorie, description, localisation, photo.
- `/signalements` (Liste): recherche + filtres (categorie, statut, quartier).
- `/tableau-de-bord` (Dashboard): KPI, graphiques et tableau de suivi.
- `*` (404): page introuvable.

### 3.2 Fonctionnalites utilisateur
- Creer un signalement depuis un formulaire.
- Joindre une photo (preview local).
- Obtenir une localisation via geolocation navigateur.
- Voir la liste des signalements et filtrer/rechercher.
- Consulter une vue dashboard de synthese.

### 3.3 Donnees
- Source actuelle: `src/data/reports.ts`.
- Typage: `Report`, `Category`, `Status`.
- Les donnees sont statiques, non persistantes, sans base de donnees.

## 4. Hors perimetre actuel
- Authentification (citoyen, agent, admin).
- Workflow serveur de traitement des signalements.
- Notifications reelles (email, SMS, push).
- Stockage media cote serveur.
- Cartographie interactive avancee.
- Historique et audit complet.

## 5. Acteurs
- Citoyen: cree et consulte les signalements.
- Agent municipal: suit les signalements et leur statut.
- Administrateur: supervise la plateforme et les indicateurs.

## 6. Exigences fonctionnelles
- EF-01: Le systeme doit permettre la creation d un signalement avec champs obligatoires (titre, description, adresse/localisation).
- EF-02: Le systeme doit proposer un choix de categorie.
- EF-03: Le systeme doit permettre l ajout d une photo locale.
- EF-04: Le systeme doit afficher un accuse de reception apres envoi.
- EF-05: Le systeme doit lister les signalements.
- EF-06: Le systeme doit permettre la recherche textuelle (titre/adresse).
- EF-07: Le systeme doit permettre des filtres par statut, categorie, quartier.
- EF-08: Le systeme doit afficher un dashboard avec indicateurs et graphiques.
- EF-09: Le systeme doit etre responsive desktop/mobile.

## 7. Exigences non fonctionnelles
- ENF-01: Performance web standard (chargement rapide sur reseau mobile moyen).
- ENF-02: Accessibilite de base (contrastes, labels, navigation claire).
- ENF-03: Maintenabilite (TypeScript, composants reutilisables, structure claire).
- ENF-04: Compatibilite navigateurs modernes (Chrome, Edge, Firefox, Safari recents).
- ENF-05: Securite frontend de base (validation formulaire locale).

## 8. Architecture technique
- Frontend: React 18 + TypeScript.
- Build/Dev server: Vite.
- UI: Tailwind CSS + composants shadcn/ui + lucide-react.
- Data viz: Recharts.
- Routing: react-router-dom.
- Etat/data: state local + donnees mockees.
- Tests: Vitest (tests unitaires basiques).

## 9. Contraintes et risques
- Pas de persistance: toute action est locale/session.
- Pas d API: impossible de tracer un vrai cycle de vie metier.
- Qualite des donnees limitee (jeu de donnees de demonstration).
- Geolocalisation depend des permissions navigateur.

## 10. Evolutions recommandees (phase 2)
- Connecter une API REST/GraphQL (CRUD signalements).
- Ajouter une base de donnees (PostgreSQL) et stockage images (S3 ou equivalent).
- Mettre en place auth/roles (citoyen, agent, admin).
- Ajouter notifications et journal d activite.
- Ajouter carte interactive (Leaflet/Mapbox) et clustering.
- Ajouter tests E2E (Playwright/Cypress).

## 11. Criteres d acceptation MVP
- CA-01: Un utilisateur peut soumettre un signalement sans erreur de validation bloquante.
- CA-02: Les pages principales sont accessibles via navigation.
- CA-03: Les filtres de la page signalements modifient correctement la liste.
- CA-04: Le dashboard affiche des KPI coherents avec les donnees mockees.
- CA-05: L interface reste utilisable sur mobile et desktop.

## 12. Livrables
- Code source frontend.
- Documentation projet (README + present cahier des charges).
- Build de production (`npm run build`).
- Tests unitaires de base (`npm run test`).

## 13. Commandes projet
- Installation: `npm install`
- Developpement: `npm run dev`
- Build production: `npm run build`
- Tests: `npm run test`

## 14. Emplacement du document
Ce document est versionne dans: `CAHIER_DES_CHARGES.md`
