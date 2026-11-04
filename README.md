# N.O.H. CloudMesh

Plateforme universitaire composée d'une application cliente Flutter (Android et Windows), d'un serveur Dart communiquant par TCP avec des messages JSON, et d'une base PostgreSQL hébergée sur Ubuntu Server 24.04. Le réseau est simulé avec EVE-NG.

Projet réalisé par l'équipe G4 de SUP'PTIC :

| Membre | Domaine principal |
|---|---|
| Abdourahim | Frontend Flutter (`client/`) |
| Olama (Vick) | Backend Dart, communication TCP, protocole partagé (`server/`, `common/`) |
| Habiba | Infrastructure EVE-NG et base de données (`database/`, `infra/`) |

> Statut : **prototype en cours de développement**. Les fonctionnalités marquées *planifiées* ne sont pas encore implémentées.

---

## Architecture

```
 Flutter (Android / Windows)                    Ubuntu Server 24.04
 ┌──────────────────────┐   TCP + trames JSON  ┌────────────────────────────┐
 │ client/              │ ───────────────────▶ │ server/  (serveur Dart)    │
 │  utilise common/     │ ◀─────────────────── │  utilise common/           │
 └──────────────────────┘                      └─────────────┬──────────────┘
                                                             │ SQL (accès interne)
                                               ┌─────────────▼──────────────┐
                                               │ PostgreSQL (database/)     │
                                               └────────────────────────────┘
```

Les clients ne se connectent jamais directement à PostgreSQL. Seul le serveur Dart y accède.

---

## Structure du dépôt

```
nohcloudmesh/
├── client/      Application Flutter
├── server/      Serveur Dart TCP
├── common/      Protocole partagé
├── database/    Scripts SQL
├── infra/       Infrastructure et réseau
└── docs/        Documentation
```

### `client/` — Application Flutter
Interface utilisateur pour Android et Windows. Elle ouvre une connexion TCP vers le serveur, envoie des requêtes et affiche les réponses.
- **Responsable :** Abdourahim
- **Contenu prévu :** écrans, gestion de l'état (Riverpod ou Provider, à choisir une seule solution), service de communication réseau.
- **Tests :** `flutter test` dans `client/`.

### `server/` — Serveur Dart
Point d'entrée du système. Il écoute sur un port TCP, accepte plusieurs clients simultanément, lit et écrit des trames, route les requêtes vers les services et accède à PostgreSQL.
- **Responsable :** Olama (Vick)
- **Contenu prévu :**
  - `bin/` : point d'entrée du serveur.
  - `lib/src/net/` : gestion des sockets, des connexions et des délais d'attente.
  - `lib/src/dispatch/` : routage des messages selon leur type.
  - `lib/src/services/` : logique métier, dont l'authentification.
  - `lib/src/db/` : connexion et requêtes PostgreSQL.
  - `lib/src/log/` : journalisation.
- **Tests :** `dart test` dans `server/`.

### `common/` — Protocole partagé
Code commun au client et au serveur, pour garantir que les deux parties parlent exactement la même langue.
- **Responsable :** Olama (Vick), avec validation des trois membres.
- **Contenu prévu :**
  - Framing : chaque message est précédé de sa longueur, ce qui permet de reconstruire les messages à partir du flux d'octets TCP.
  - Modèles JSON partagés et sérialisation.
  - Types de messages, identifiants de requête et codes d'erreur.
- **Tests :** `dart test` dans `common/`.
- **Règle :** toute modification passe par une petite pull request annoncée à l'équipe avant fusion.

### `database/` — Base de données
Scripts SQL pour créer le schéma et insérer les données initiales.
- **Responsable :** Habiba
- **Contenu :** schéma, tables, données de test.

### `infra/` — Infrastructure
Tout ce qui permet de faire tourner le système hors du poste de développement.
- **Responsable :** Habiba
- **Contenu :** topologies EVE-NG, configuration Ubuntu Server, fichiers systemd, règles de pare-feu.

### `docs/` — Documentation
- Feuille de route du projet.
- Spécification du protocole JSON.
- Guides d'installation et de travail Git.
- Rapports de tests.

---

## Fonctionnalités

| Fonctionnalité | Description | Statut |
|---|---|---|
| Serveur TCP multi-clients | Accepte plusieurs connexions simultanées et gère les déconnexions | Planifiée |
| Framing des messages | Découpe le flux TCP en messages complets à partir de leur longueur | Planifiée |
| Protocole JSON | Requêtes et réponses avec identifiant, type, et erreurs normalisées | Planifiée (à valider) |
| Connexion PostgreSQL | Accès à la base depuis le serveur uniquement | Planifiée |
| Authentification | Inscription et connexion, mots de passe hachés | Planifiée |
| Journalisation | Trace des événements importants côté serveur | Planifiée |
| Application Flutter | Interface mobile et Windows connectée au serveur | Planifiée |
| Déploiement | Serveur lancé sur Ubuntu Server avec systemd | Planifiée |

Les fonctionnalités métier au-delà de l'authentification sont à définir avec l'équipe.

---

## Installation

Les logiciels nécessaires sont listés dans le *Guide d'installation des logiciels et extensions*, dans `docs/`.

```bash
git clone https://github.com/<compte>/nohcloudmesh.git
cd nohcloudmesh
git checkout dev
git pull origin dev
```

Vérifier l'environnement :

```bash
flutter doctor -v
dart --version
git --version
```

Installer les dépendances de chaque partie :

```bash
cd common && dart pub get && cd ..
cd server && dart pub get && cd ..
cd client && flutter pub get && cd ..
```

---

## Lancer le projet

Lancer le serveur :

```bash
cd server
dart run bin/server.dart
```

Tester que le port répond (depuis une autre fenêtre) :

```bash
nc localhost <port>
```

Lancer l'application Flutter :

```bash
cd client
flutter run
```

> Le port, l'adresse du serveur et les identifiants de connexion à PostgreSQL sont définis dans un fichier `.env` local. Ce fichier n'est jamais versionné.

---

## Tests

| Partie | Commande |
|---|---|
| Protocole | `cd common && dart test` |
| Serveur | `cd server && dart test` |
| Application | `cd client && flutter test` |

---

## Workflow Git

- `main` : version stable, protégée. Ne reçoit que des fins de sprint.
- `dev` : intégration des fonctionnalités, protégée.
- Une branche par tâche du backlog, nommée par son identifiant : `feat/S2-06-auth`, `fix/…`, `docs/…`.
- Toute modification passe par une pull request, relue par le responsable du domaine et un second membre.
- Commits au format Conventional Commits : `feat(server) : ajoute …`, `fix(common) : gère …`.

Le guide complet est dans `docs/`.

---

## Sécurité

- Aucun secret ni mot de passe dans le dépôt. Les fichiers `.env` sont ignorés par Git.
- Les mots de passe sont stockés sous forme hachée, jamais en clair.
- TCP ne chiffre pas les échanges. Le prototype fonctionne sur un réseau local isolé. TLS est prévu avant toute mise en production.
- PostgreSQL n'est accessible que depuis le serveur applicatif, filtré par le pare-feu.

---

## Documentation

- `docs/roadmap` : plan de travail par phase.
- `docs/protocole` : format des messages (à compléter après validation).
- `docs/guide-git` : organisation des branches et des pull requests.
- `docs/guide-logiciels` : installation des outils et extensions.