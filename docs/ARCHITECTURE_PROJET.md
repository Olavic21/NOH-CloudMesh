# Architecture du Projet N.O.H. CloudMesh

**Version :** 1.0  
**Date :** 17 novembre 2026  
**Équipe :** Abdourahim, Olama, Habiba

---

## 1. Structure Globale du Projet

```
NOH-CloudMesh/
├── .github/                    # Configuration GitHub
│   └── workflows/              # Workflows CI/CD
│       ├── ci-common.yml       # CI code commun
│       ├── ci-server.yml       # CI serveur
│       ├── ci-client.yml       # CI client Flutter
│       └── ci.yml              # CI global
│
├── client/                     # Application Flutter (client)
│   ├── lib/
│   │   ├── core/               # Cœur de l'application
│   │   │   ├── network/        # Communication TCP
│   │   │   ├── session/        # Gestion session
│   │   │   └── theme/          # Thème UI
│   │   ├── models/             # Modèles de données
│   │   ├── services/           # Services TCP
│   │   ├── features/           # Fonctionnalités par module
│   │   │   ├── authentication/  # Authentification (Abdourahim)
│   │   │   ├── requests/       # Demandes (Olama)
│   │   │   └── notifications/   # Notifications (Habiba)
│   │   └── main.dart           # Point d'entrée
│   ├── test/                   # Tests Flutter
│   ├── pubspec.yaml            # Dépendances Flutter
│   └── android/                # Configuration Android
│
├── server/                     # Serveur Dart
│   ├── bin/
│   │   └── server.dart         # Point d'entrée serveur
│   ├── lib/
│   │   ├── network/            # TCP, framing
│   │   ├── protocol/           # Définitions protocole
│   │   ├── auth/               # Authentification (Abdourahim)
│   │   ├── services/           # Services métier (Olama)
│   │   ├── notifications/      # Notifications (Habiba)
│   │   ├── database/           # PostgreSQL
│   │   └── config/             # Configuration
│   ├── test/                   # Tests serveur
│   ├── uploads/                # Stockage fichiers
│   └── pubspec.yaml            # Dépendances Dart
│
├── common/                     # Code partagé client/serveur
│   ├── lib/
│   │   ├── framing.dart        # Framing TCP
│   │   ├── protocol.dart       # Définitions protocole
│   │   └── models.dart         # Modèles partagés
│   ├── test/                   # Tests communs
│   └── pubspec.yaml            # Dépendances
│
├── database/                   # Scripts SQL
│   ├── migrations/             # Migrations
│   ├── seeds/                  # Données de test
│   └── schema.sql              # Schéma initial
│
├── docs/                       # Documentation
│   ├── protocole.md            # Documentation protocole
│   ├── architecture.md         # Ce fichier
│   └── api/                    # Documentation API
│
├── DOCUMENTATION_EQUIPE/       # Documentation équipe
│   ├── DOCUMENTATION_ABDOURAHIM.md
│   ├── DOCUMENTATION_OLAMA.md
│   ├── DOCUMENTATION_HABIBA.md
│   └── ORGANISATION_TECHNIQUE_EQUIPE.md
│
├── README.md                   # README public
├── README FINAL.md             # README technique complet
├── .gitignore                  # Fichiers ignorés Git
└── pubspec.yaml                # Dépendances racine (optionnel)
```

---

## 2. Rôle des Dossiers et Fichiers

### 2.1. `.github/` — Configuration GitHub

**Rôle :** Configuration de l'intégration continue et des fonctionnalités GitHub.

**Fichiers :**
- `workflows/ci-common.yml` — CI pour le code commun
- `workflows/ci-server.yml` — CI pour le serveur
- `workflows/ci-client.yml` — CI pour le client Flutter
- `workflows/ci.yml` — CI global orchestrateur

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

---

### 2.2. `client/` — Application Flutter

**Rôle :** Application cliente Flutter pour étudiants, agents et administrateurs.

**Sous-dossiers :**

#### `client/lib/core/` — Cœur de l'application

**Rôle :** Fonctionnalités communes à tous les modules.

**Fichiers :**
- `network/` — Communication TCP (framing, Socket)
- `session/` — Gestion de session (token, état)
- `theme/` — Thème UI (couleurs, styles)

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

#### `client/lib/models/` — Modèles de données

**Rôle :** Modèles Dart pour les données (User, Request, Notification, etc.).

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

#### `client/lib/services/` — Services TCP

**Rôle :** Services pour communiquer avec le serveur.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

#### `client/lib/features/authentication/` — Authentification

**Rôle :** Écrans et logique d'authentification.

**Fichiers :**
- `login_screen.dart` — Écran de connexion
- `profile_screen.dart` — Écran de profil
- `admin_user_management_screen.dart` — Gestion utilisateurs (admin)

**Responsable principal :** Abdourahim

**Permissions :**
- **Abdourahim :** Lecture, modification (principal)
- **Olama :** Lecture, modification (secondaire)
- **Habiba :** Lecture, modification (secondaire)

#### `client/lib/features/requests/` — Gestion des demandes

**Rôle :** Écrans et logique de gestion des demandes.

**Fichiers :**
- `new_request_screen.dart` — Nouvelle demande
- `my_requests_screen.dart` — Mes demandes
- `request_details_screen.dart` — Détails demande
- `agent_requests_screen.dart` — Traitement demandes (agent)

**Responsable principal :** Olama

**Permissions :**
- **Abdourahim :** Lecture, modification (secondaire)
- **Olama :** Lecture, modification (principal)
- **Habiba :** Lecture, modification (secondaire)

#### `client/lib/features/notifications/` — Notifications

**Rôle :** Écrans et logique de notifications.

**Fichiers :**
- `notifications_screen.dart` — Liste notifications
- `request_history_screen.dart` — Historique
- `notification_banner.dart` — Bannière temps réel

**Responsable principal :** Habiba

**Permissions :**
- **Abdourahim :** Lecture, modification (secondaire)
- **Olama :** Lecture, modification (secondaire)
- **Habiba :** Lecture, modification (principal)

#### `client/lib/main.dart` — Point d'entrée

**Rôle :** Point d'entrée de l'application Flutter.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

#### `client/test/` — Tests Flutter

**Rôle :** Tests unitaires et d'intégration Flutter.

**Responsable :** Chaque membre teste son module

**Permissions :**
- **Abdourahim :** Lecture, modification (tests authentification)
- **Olama :** Lecture, modification (tests demandes)
- **Habiba :** Lecture, modification (tests notifications)

#### `client/pubspec.yaml` — Dépendances Flutter

**Rôle :** Dépendances et configuration Flutter.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

---

### 2.3. `server/` — Serveur Dart

**Rôle :** Serveur TCP Dart avec PostgreSQL.

**Sous-dossiers :**

#### `server/lib/network/` — Réseau

**Rôle :** TCP, framing, gestion des connexions.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

#### `server/lib/protocol/` — Protocole

**Rôle :** Définitions du protocole TCP et JSON.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

#### `server/lib/auth/` — Authentification

**Rôle :** Services d'authentification, sessions, utilisateurs.

**Fichiers :**
- `auth_service.dart` — Service authentification
- `user_service.dart` — Service utilisateurs
- `session_service.dart` — Service sessions

**Responsable principal :** Abdourahim

**Permissions :**
- **Abdourahim :** Lecture, modification (principal)
- **Olama :** Lecture, modification (secondaire)
- **Habiba :** Lecture, modification (secondaire)

#### `server/lib/services/` — Services métier

**Rôle :** Services de gestion des demandes et pièces jointes.

**Fichiers :**
- `request_service.dart` — Service demandes
- `attachment_service.dart` — Service pièces jointes

**Responsable principal :** Olama

**Permissions :**
- **Abdourahim :** Lecture, modification (secondaire)
- **Olama :** Lecture, modification (principal)
- **Habiba :** Lecture, modification (secondaire)

#### `server/lib/notifications/` — Notifications

**Rôle :** Services de notifications et historique.

**Fichiers :**
- `notification_service.dart` — Service notifications
- `history_service.dart` — Service historique

**Responsable principal :** Habiba

**Permissions :**
- **Abdourahim :** Lecture, modification (secondaire)
- **Olama :** Lecture, modification (secondaire)
- **Habiba :** Lecture, modification (principal)

#### `server/lib/database/` — Base de données

**Rôle :** Connexion PostgreSQL, requêtes, migrations.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

#### `server/lib/config/` — Configuration

**Rôle :** Configuration serveur (ports, DB, etc.).

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

#### `server/bin/server.dart` — Point d'entrée

**Rôle :** Point d'entrée du serveur.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

#### `server/test/` — Tests serveur

**Rôle :** Tests unitaires et d'intégration serveur.

**Responsable :** Chaque membre teste son module

**Permissions :**
- **Abdourahim :** Lecture, modification (tests authentification)
- **Olama :** Lecture, modification (tests demandes)
- **Habiba :** Lecture, modification (tests notifications)

#### `server/uploads/` — Stockage fichiers

**Rôle :** Stockage des fichiers uploadés.

**Responsable :** Olama (principal), tous (accès)

**Permissions :**
- **Abdourahim :** Lecture
- **Olama :** Lecture, modification
- **Habiba :** Lecture

#### `server/pubspec.yaml` — Dépendances Dart

**Rôle :** Dépendances et configuration Dart.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

---

### 2.4. `common/` — Code partagé

**Rôle :** Code partagé entre client et serveur (framing, protocole, modèles).

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

---

### 2.5. `database/` — Scripts SQL

**Rôle :** Migrations, schéma et données de test PostgreSQL.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

---

### 2.6. `docs/` — Documentation

**Rôle :** Documentation technique du projet.

**Fichiers :**
- `protocole.md` — Documentation du protocole TCP
- `architecture.md` — Ce fichier
- `api/` — Documentation API

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

---

### 2.7. `DOCUMENTATION_EQUIPE/` — Documentation équipe

**Rôle :** Guides de travail pour chaque membre.

**Fichiers :**
- `DOCUMENTATION_ABDOURAHIM.md` — Guide Abdourahim
- `DOCUMENTATION_OLAMA.md` — Guide Olama
- `DOCUMENTATION_HABIBA.md` — Guide Habiba
- `ORGANISATION_TECHNIQUE_EQUIPE.md` — Organisation technique

**Responsable :** Collectif, mais chaque membre peut modifier son propre guide

**Permissions :**
- **Abdourahim :** Lecture, modification (tous les fichiers)
- **Olama :** Lecture, modification (tous les fichiers)
- **Habiba :** Lecture, modification (tous les fichiers)

---

### 2.8. Fichiers racine

#### `README.md` — README public

**Rôle :** Présentation publique du projet.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

#### `README FINAL.md` — README technique

**Rôle :** Spécification technique complète.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

#### `.gitignore` — Fichiers ignorés

**Rôle :** Configuration Git des fichiers à ignorer.

**Responsable :** Tous les membres (collectif)

**Permissions :**
- **Abdourahim :** Lecture, modification
- **Olama :** Lecture, modification
- **Habiba :** Lecture, modification

---

## 3. Matrice des Permissions

### 3.1. Résumé par membre

| Dossier/Fichier | Abdourahim | Olama | Habiba |
|---|---|---|---|
| `.github/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `client/lib/core/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `client/lib/models/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `client/lib/services/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `client/lib/features/authentication/` | ✅ ✅ ⭐ | ✅ ✅ | ✅ ✅ |
| `client/lib/features/requests/` | ✅ ✅ | ✅ ✅ ⭐ | ✅ ✅ |
| `client/lib/features/notifications/` | ✅ ✅ | ✅ ✅ | ✅ ✅ ⭐ |
| `client/lib/main.dart` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `client/test/` | ✅ ✅ ⭐ | ✅ ✅ ⭐ | ✅ ✅ ⭐ |
| `client/pubspec.yaml` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `server/lib/network/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `server/lib/protocol/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `server/lib/auth/` | ✅ ✅ ⭐ | ✅ ✅ | ✅ ✅ |
| `server/lib/services/` | ✅ ✅ | ✅ ✅ ⭐ | ✅ ✅ |
| `server/lib/notifications/` | ✅ ✅ | ✅ ✅ | ✅ ✅ ⭐ |
| `server/lib/database/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `server/lib/config/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `server/bin/server.dart` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `server/test/` | ✅ ✅ ⭐ | ✅ ✅ ⭐ | ✅ ✅ ⭐ |
| `server/uploads/` | ✅ | ✅ ✅ ⭐ | ✅ |
| `server/pubspec.yaml` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `common/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `database/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `docs/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `DOCUMENTATION_EQUIPE/` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `README.md` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `README FINAL.md` | ✅ ✅ | ✅ ✅ | ✅ ✅ |
| `.gitignore` | ✅ ✅ | ✅ ✅ | ✅ ✅ |

**Légende :**
- ✅ = Lecture
- ✅ ✅ = Lecture et modification
- ⭐ = Responsable principal

### 3.2. Règles de modification

**Principe de polyvalence :**
- Chaque membre peut lire et modifier tous les fichiers
- Les responsabilités principales indiquent qui doit initialement développer et maintenir le module
- En cas de conflit ou d'absence, les autres membres peuvent intervenir

**Processus de modification :**
1. Le responsable principal effectue les modifications
2. Si le responsable principal est absent, les autres membres peuvent modifier
3. Toute modification critique doit être revue par au moins un autre membre
4. Les modifications dans le module d'un autre membre doivent être communiquées

**Exceptions :**
- `server/uploads/` : Seul Olama peut modifier (stockage fichiers)
- Tests : Chaque membre modifie les tests de son module

---

## 4. Flux de Travail Recommandé

### 4.1. Pour Abdourahim

1. **Travail principal :** `client/lib/features/authentication/` et `server/lib/auth/`
2. **Collaboration :** Peut modifier les modules d'Olama et Habiba en cas de besoin
3. **Tests :** Écrit les tests pour l'authentification
4. **Review :** Review les modifications d'Olama et Habiba

### 4.2. Pour Olama

1. **Travail principal :** `client/lib/features/requests/` et `server/lib/services/`
2. **Collaboration :** Peut modifier les modules d'Abdourahim et Habiba en cas de besoin
3. **Tests :** Écrit les tests pour les demandes
4. **Review :** Review les modifications d'Abdourahim et Habiba

### 4.3. Pour Habiba

1. **Travail principal :** `client/lib/features/notifications/` et `server/lib/notifications/`
2. **Collaboration :** Peut modifier les modules d'Abdourahim et Olama en cas de besoin
3. **Tests :** Écrit les tests pour les notifications
4. **Review :** Review les modifications d'Abdourahim et Olama

---

## 5. Conventions de Nommage

### 5.1. Fichiers Dart

**Client Flutter :**
- Écrans : `nom_screen.dart` (ex: `login_screen.dart`)
- Widgets : `nom_widget.dart` (ex: `request_card.dart`)
- Services : `nom_service.dart` (ex: `auth_service.dart`)
- Modèles : `nom.dart` (ex: `user.dart`)

**Serveur Dart :**
- Services : `nom_service.dart` (ex: `request_service.dart`)
- Handlers : `nom_handler.dart` (ex: `login_handler.dart`)
- Modèles : `nom.dart` (ex: `user.dart`)

### 5.2. Dossiers

- **snake_case** pour tous les dossiers
- Pluriel pour les collections (ex: `models/`, `services/`)
- Singulier pour les concepts (ex: `auth/`, `network/`)

### 5.3. Classes Dart

- **PascalCase** pour les classes (ex: `AuthService`, `RequestCard`)
- **camelCase** pour les variables et méthodes (ex: `userId`, `login()`)
- **UPPER_CASE** pour les constantes (ex: `MAX_FILE_SIZE`)

---

## 6. Notes Importantes

### 6.1. Principe de polyvalence

Cette architecture respecte le principe de polyvalence : aucun membre n'est limité à son module principal. Chacun peut :

- Lire et modifier tout le code
- Comprendre l'ensemble du système
- Intervenir en cas de besoin
- Participer aux tests et reviews

### 6.2. Responsabilités principales

Les responsabilités principales indiquent :
- Qui doit initialement développer le module
- Qui est le point de contact pour les questions
- Qui doit maintenir le code à jour

Elles ne sont pas des restrictions d'accès.

### 6.3. Collaboration

La collaboration est encouragée :
- Revue croisée du code
- Partage des connaissances
- Entraide en cas de blocage
- Décisions collectives pour les changements majeurs

---

**Document rédigé pour l'équipe N.O.H. CloudMesh — Architecture du Projet**

**Ce document constitue la référence pour l'organisation du code et les permissions.**
