# ORGANISATION TECHNIQUE DE L'ÉQUIPE

**Projet :** N.O.H. CloudMesh  
**Équipe :** Abdourahim, Olama, Habiba  
**Durée :** 4 semaines

---

## 1. Architecture Technique Globale

### 1.1. Vue d'ensemble

N.O.H. CloudMesh adopte une architecture client-serveur centralisée sur réseau local (LAN).

```text
                    RÉSEAU LOCAL (LAN)
                           |
        +------------------+------------------+
        |                  |                  |
    Étudiant            Agent              Admin
    Flutter            Flutter            Flutter
        |                  |                  |
        +------------------+------------------+
                           |
                    TCP / JSON (Port 8080)
                           |
        +----------------------------------+
        |       SERVEUR DART                |
        |----------------------------------|
        | - Authentification (Abdourahim)  |
        | - Gestion demandes (Olama)        |
        | - Notifications (Habiba)          |
        | - TCP Server (collectif)          |
        +----------------------------------+
                           |
                    PostgreSQL
```

### 1.2. Couches techniques

**Couche cliente (Flutter/Dart)**
- Trois interfaces : étudiant, agent, administrateur
- Communication TCP via `Socket`
- Framing : préfixe 4 octets Big Endian
- Messages JSON encodés UTF-8

**Couche serveur (Dart)**
- `ServerSocket` pour écouter les connexions
- Gestion des connexions simultanées (cible 50)
- Services métier : authentification, demandes, notifications
- Pool PostgreSQL : 15 connexions

**Couche données (PostgreSQL)**
- Tables : users, sessions, requests, request_history, attachments, notifications
- Transactions pour les opérations critiques
- Index pour optimiser les requêtes fréquentes

### 1.3. Technologies

- **Client :** Flutter 3.x, Dart 3.x
- **Serveur :** Dart 3.x, Ubuntu Server 24.04 LTS
- **Base de données :** PostgreSQL 16
- **Transport :** TCP (pas de TLS dans le MVP)
- **Format :** JSON
- **Tests réseau :** Wireshark (collectif)

---

## 2. Répartition des Responsabilités Fonctionnelles

### 2.1. Abdourahim — Authentification et Gestion des Utilisateurs

**Module principal :** Point d'entrée de l'application

**Fonctionnalités :**
- Connexion et déconnexion
- Gestion des profils utilisateurs
- Création et désactivation de comptes (admin)
- Attribution de rôles
- Gestion des sessions
- Verrouillage de comptes

**Tables PostgreSQL :**
- `users` (conception principale)
- `sessions` (conception principale)

**Interfaces Flutter :**
- LoginScreen
- ProfileScreen
- AdminUserManagementScreen

**Services Dart :**
- AuthService (hachage bcrypt, tokens)
- UserService (CRUD utilisateurs)
- SessionService (gestion sessions)

### 2.2. Olama — Gestion des Demandes Administratives

**Module principal :** Cœur fonctionnel de l'application

**Fonctionnalités :**
- Soumission de demandes
- Consultation des demandes
- Modification des statuts
- Gestion des pièces jointes
- Upload/download de fichiers
- Historisation des changements

**Tables PostgreSQL :**
- `requests` (conception principale)
- `request_history` (conception principale avec Habiba)
- `attachments` (conception principale)

**Interfaces Flutter :**
- NewRequestScreen
- MyRequestsScreen
- RequestDetailsScreen
- AgentRequestsScreen

**Services Dart :**
- RequestService (CRUD demandes, transitions)
- AttachmentService (transfert fichiers, SHA-256)

### 2.3. Habiba — Suivi des Demandes et Notifications

**Module principal :** Traçabilité et communication

**Fonctionnalités :**
- Affichage de l'historique
- Consultation des notifications
- Réception temps réel des événements
- Récupération après reconnexion
- Acquittement des notifications

**Tables PostgreSQL :**
- `notifications` (conception principale)
- `request_history` (conception avec Olama)

**Interfaces Flutter :**
- RequestHistoryScreen
- NotificationsScreen
- NotificationBanner (widget temps réel)

**Services Dart :**
- NotificationService (création, diffusion, persistance)
- HistoryService (consultation historique)

---

## 3. Responsabilités Techniques Communes

### 3.1. Principe de polyvalence

**Règle fondamentale :** Aucun membre n'est spécialisé exclusivement en frontend, backend ou réseaux.

**Chaque membre doit :**
- Développer en Flutter (widgets, navigation, état)
- Développer en Dart côté serveur (services, logique métier)
- Implémenter la communication TCP (Socket, framing)
- Écrire des requêtes SQL (PostgreSQL)
- Participer aux tests (unitaires, intégration, réseau)
- Utiliser Git et GitHub

### 3.2. Activités collectives

**Développement TCP :**
- Conception du protocole (collective)
- Implémentation du framing (collective)
- Tests Wireshark (collectif)
- Validation des messages (collective)

**Tests et validation :**
- Tests de connexions simultanées (collectif)
- Tests de reconnexion (collectif)
- Analyse Wireshark (collectif)
- Tests fonctionnels (collectif)

**Intégration :**
- Revue croisée du code (collective)
- Résolution des incompatibilités (collective)
- Tests d'intégration (collectif)

**Important :** Habiba n'est pas responsable exclusive des tests réseau. Ces activités sont partagées entre les trois membres.

### 3.3. Compétences à acquérir par tous

| Compétence | Niveau attendu |
|---|---|
| Flutter widgets | Intermédiaire |
| Dart async/await | Intermédiaire |
| Dart Socket | Intermédiaire |
| PostgreSQL SQL | Intermédiaire |
| Git/GitHub | Intermédiaire |
| Wireshark | Basique |

---

## 4. Dépendances entre les Modules

### 4.1. Graphe des dépendances

```text
                    Authentification (Abdourahim)
                               |
                +--------------+--------------+
                |                             |
        Gestion demandes (Olama)   Suivi/Notifications (Habiba)
                |                             |
                +--------------+--------------+
                               |
                         PostgreSQL
```

### 4.2. Dépendances fonctionnelles

**Olama dépend d'Abdourahim :**
- Validation des tokens pour chaque requête
- Informations utilisateur (id, rôle)
- Vérification des permissions

**Habiba dépend d'Abdourahim :**
- Validation des tokens
- Identification des connexions actives
- Informations utilisateur pour cibler les notifications

**Habiba dépend d'Olama :**
- Déclenchement des notifications lors des changements de statut
- Accès à l'historique des demandes
- Contexte des demandes pour les notifications

**Abdourahim dépend de :**
- Aucune dépendance fonctionnelle directe (module autonome)

### 4.3. Ordre de développement recommandé

**Semaine 1 :**
1. Abdourahim : authentification de base
2. Olama : structure des demandes
3. Habiba : structure des notifications

**Semaine 2 :**
1. Abdourahim : sessions complètes
2. Olama : CRUD demandes
3. Habiba : création notifications

**Semaine 3 :**
1. Intégration Abdourahim → Olama
2. Intégration Olama → Habiba
3. Tests croisés

---

## 5. Interfaces entre Modules

### 5.1. API interne (Dart serveur)

**Fournie par Abdourahim :**

```dart
// Validation d'un token
Future<UserInfo?> validateToken(String token);

// Récupération des infos utilisateur
Future<User> getUserById(int userId);

// Vérification des permissions
bool hasPermission(User user, String action);
```

**Fournie par Olama :**

```dart
// Création d'une demande
Future<Request> createRequest(CreateRequestDto dto);

// Modification du statut
Future<void> updateStatus(int requestId, String newStatus, int actorId, String? comment);

// Récupération de l'historique
Future<List<HistoryEntry>> getHistory(int requestId);

// Notification d'un changement de statut
void notifyStatusChange(int requestId, String newStatus);
```

**Fournie par Habiba :**

```dart
// Création d'une notification
Future<Notification> createNotification(int userId, String eventType, Map payload);

// Diffusion aux clients connectés
void broadcastNotification(int userId, Notification notification);

// Récupération des notifications
Future<List<Notification>> getUserNotifications(int userId);
```

### 5.2. Protocole TCP (actions)

**Actions d'Abdourahim :**
- LOGIN
- LOGOUT
- CREATE_USER
- UPDATE_PROFILE

**Actions d'Olama :**
- SUBMIT_REQUEST
- GET_MY_REQUESTS
- GET_REQUEST_DETAILS
- UPDATE_REQUEST_STATUS
- UPLOAD_ATTACHMENT
- DOWNLOAD_ATTACHMENT

**Actions d'Habiba :**
- GET_REQUEST_HISTORY
- GET_NOTIFICATIONS
- ACK_NOTIFICATION

**Événements serveur (Habiba) :**
- REQUEST_STATUS_CHANGED
- NEEDS_INFO
- REQUEST_APPROVED
- REQUEST_REJECTED

### 5.3. Schéma PostgreSQL

**Tables d'Abdourahim :**
- `users` : id, username, password_hash, email, role, is_active, failed_login_attempts, locked_until
- `sessions` : id, user_id, token, expires_at, created_at, last_activity

**Tables d'Olama :**
- `requests` : id, user_id, request_type, description, status, service, created_at, updated_at
- `request_history` : id, request_id, previous_status, new_status, actor_id, comment, created_at
- `attachments` : id, request_id, original_name, stored_name, mime_type, file_size, storage_path, checksum, upload_status

**Tables d'Habiba :**
- `notifications` : id, user_id, event_id, event_type, payload, is_read, read_at, created_at

---

## 6. Conventions Communes de Développement

### 6.1. Convention de nommage

**Dart :**
- Classes : PascalCase (AuthService, RequestService)
- Variables : camelCase (userId, requestType)
- Constantes : camelCase ou UPPER_CASE (MAX_FILE_SIZE)
- Privées : préfixe _ (_socket, _validateToken)

**PostgreSQL :**
- Tables : snake_case (users, request_history)
- Colonnes : snake_case (user_id, created_at)
- Index : idx_table_column (idx_requests_user)

**Flutter :**
- Widgets : PascalCase (LoginScreen, RequestCard)
- Fichiers : snake_case (login_screen.dart, request_card.dart)

### 6.2. Convention de code

**Structure des fichiers Dart :**

```dart
// Imports
import 'package:...';

// Documentation
/// Description de la classe
class MyClass {
  // Constantes
  static const int MAX_SIZE = 100;

  // Propriétés privées
  final String _name;

  // Constructeur
  MyClass(this._name);

  // Méthodes publiques
  void doSomething() {
    // Implementation
  }

  // Méthodes privées
  void _validate() {
    // Implementation
  }
}
```

**Commentaires :**
- Documentation publique avec ///
- Commentaires d'implémentation avec //
- Pas de commentaires évidents (ex: // incrémenter i)

### 6.3. Gestion des erreurs

**Exceptions Dart :**

```dart
try {
  final result = await someOperation();
  return result;
} on SocketException catch (e) {
  throw NetworkException('Erreur réseau: $e');
} on PostgreSQLException catch (e) {
  throw DatabaseException('Erreur base de données: $e');
} catch (e) {
  throw UnknownException('Erreur inconnue: $e');
}
```

**Réponses TCP :**

```json
{
  "request_id": "req-001",
  "status": "ERROR",
  "data": null,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Message utilisateur-friendly"
  }
}
```

**Règle :** Ne jamais exposer d'informations sensibles dans les erreurs (stack traces, détails internes).

### 6.4. Convention Git

**Branches :**
- `main` : branche principale stable
- `dev` : branche de développement
- `feature/nom-fonctionnalite` : branches de fonctionnalités

**Messages de commit :**
```
feat: ajouter l'écran de connexion
fix: corriger le bug de validation
docs: mettre à jour la README
refactor: restructurer AuthService
test: ajouter tests pour UserService
```

**Pull requests :**
- Titre descriptif
- Description des changements
- Référence aux issues si applicable
- Au moins une review par un autre membre

---

## 7. Organisation Git et GitHub

### 7.1. Structure du dépôt

```text
NOH-CloudMesh/
├── client/                    # Application Flutter
│   ├── lib/
│   │   ├── core/             # Réseau, protocole, session
│   │   ├── models/           # Modèles de données
│   │   ├── services/         # Services TCP
│   │   ├── features/         # Fonctionnalités par module
│   │   │   ├── authentication/
│   │   │   ├── requests/
│   │   │   └── notifications/
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── test/
├── server/                    # Serveur Dart
│   ├── lib/
│   │   ├── network/          # TCP, framing
│   │   ├── protocol/         # Définitions protocole
│   │   ├── auth/             # AuthService (Abdourahim)
│   │   ├── services/          # RequestService (Olama)
│   │   ├── notifications/    # NotificationService (Habiba)
│   │   ├── database/         # PostgreSQL
│   │   └── main.dart
│   ├── pubspec.yaml
│   ├── uploads/              # Stockage fichiers
│   └── test/
├── database/                  # Scripts SQL
├── docs/                      # Documentation
└── DOCUMENTATION_EQUIPE/      # Documentation équipe
```

### 7.2. Workflow Git

**Début d'une fonctionnalité :**

```bash
git checkout dev
git pull origin dev
git checkout -b feature/ma-fonctionnalite
```

**Travail quotidien :**

```bash
git add .
git commit -m "feat: description"
git push origin feature/ma-fonctionnalite
```

**Fin d'une fonctionnalité :**

```bash
git checkout dev
git pull origin dev
git merge feature/ma-fonctionnalite
git push origin dev
```

**Pull request :**
1. Créer une PR sur GitHub
2. Demander une review à au moins un autre membre
3. Corriger selon les commentaires
4. Merger après approbation

### 7.3. Résolution de conflits

**Principes :**
- Communiquer avant de merger
- Résoudre les conflits localement
- Tester après résolution
- Demander une review si le conflit est complexe

---

## 8. Stratégie d'Intégration Frontend/Backend

### 8.1. Approche progressive

**Semaine 1 : Prototypes séparés**
- Frontend : écrans avec données mockées
- Backend : services avec tests unitaires
- TCP : prototype client-serveur basique

**Semaine 2 : Développement parallèle**
- Frontend : écrans complets sans connexion réelle
- Backend : services complets avec PostgreSQL
- TCP : framing et actions implémentées

**Semaine 3 : Intégration**
- Frontend : connexion au serveur TCP
- Backend : gestion des connexions réelles
- Tests : scénarios bout-en-bout

**Semaine 4 : Validation**
- Tests fonctionnels complets
- Tests de charge
- Corrections finales

### 8.2. Mocking pour le développement

**Pendant le développement frontend :**

```dart
class MockTcpClient extends TcpClient {
  @override
  Future<Map<String, dynamic>> sendRequest(Map<String, dynamic> request) async {
    // Retourner des réponses mockées selon l'action
    switch (request['action']) {
      case 'LOGIN':
        return {'status': 'SUCCESS', 'data': {'token': 'mock-token'}};
      default:
        return {'status': 'ERROR', 'error': {'code': 'NOT_IMPLEMENTED'}};
    }
  }
}
```

### 8.3. Tests d'intégration

**Scénario 1 : Authentification → Soumission**

```dart
test('Flux complet : login → submit request', () async {
  // 1. Login
  final loginResponse = await client.sendRequest({
    'action': 'LOGIN',
    'payload': {'username': 'test', 'password': 'test'}
  });
  expect(loginResponse['status'], 'SUCCESS');
  
  final token = loginResponse['data']['token'];
  
  // 2. Submit request
  final submitResponse = await client.sendRequest({
    'action': 'SUBMIT_REQUEST',
    'token': token,
    'payload': {'request_type': 'ATTESTATION_SCOLARITE'}
  });
  expect(submitResponse['status'], 'SUCCESS');
});
```

---

## 9. Stratégie de Tests Collectifs

### 9.1. Types de tests

**Tests unitaires :**
- Chaque membre teste ses propres services
- Isolés des dépendances externes
- Rapides et fréquents

**Tests d'intégration :**
- Tests entre modules (ex: authentification + demandes)
- Nécessitent PostgreSQL
- Plus lents

**Tests TCP :**
- Validation du framing
- Tests avec Wireshark
- Collectifs

**Tests fonctionnels :**
- Scénarios bout-en-bout
- Simulent l'utilisation réelle
- Collectifs en semaine 4

### 9.2. Calendrier des tests

**Semaine 1 :**
- Tests unitaires des services de base
- Tests TCP du framing

**Semaine 2 :**
- Tests unitaires complets
- Tests d'intégration PostgreSQL

**Semaine 3 :**
- Tests d'intégration entre modules
- Tests TCP des actions complètes

**Semaine 4 :**
- Tests fonctionnels bout-en-bout
- Tests de charge
- Tests de reconnexion

### 9.3. Outils de test

**Dart :**
- `test` package pour les tests unitaires
- `mockito` pour le mocking
- `integration_test` pour les tests Flutter

**PostgreSQL :**
- Base de données de test séparée
- Données de test reproductibles

**Réseau :**
- Wireshark pour capture et analyse
- Scripts de test TCP

---

## 10. Calendrier de Travail sur Quatre Semaines

### Semaine 1 — Fondations Communes

**Objectif :** Prototype client-serveur fonctionnel et compréhension partagée

**Lundi :**
- **Tous :** Apprentissage Flutter et Dart (widgets, async)
- **Tous :** Compréhension du README FINAL.md

**Mardi :**
- **Tous :** Conception des tables PostgreSQL (réunion)
- **Abdourahim :** Prototype LoginScreen
- **Olama :** Prototype NewRequestScreen
- **Habiba :** Prototype NotificationsScreen

**Mercredi :**
- **Tous :** Prototype client TCP (framing)
- **Tous :** Prototype serveur TCP (réception)
- **Tous :** Tests avec Wireshark

**Jeudi :**
- **Abdourahim :** Prototype AuthService
- **Olama :** Prototype RequestService
- **Habiba :** Prototype NotificationService
- **Tous :** Intégration prototype

**Vendredi :**
- **Tous :** Validation prototype TCP
- **Tous :** Documentation du framing
- **Tous :** Bilan de semaine

**Livrables :**
- Prototype TCP opérationnel
- Écrans principaux en prototype
- Services de base en prototype
- Documentation du framing

### Semaine 2 — Développement des Modules

**Objectif :** Composants principaux fonctionnels indépendamment

**Lundi :**
- **Abdourahim :** AuthService complet (bcrypt, tokens)
- **Olama :** RequestService complet (CRUD)
- **Habiba :** NotificationService complet

**Mardi :**
- **Abdourahim :** UserService, SessionService
- **Olama :** AttachmentService (transfert fichiers)
- **Habiba :** HistoryService

**Mercredi :**
- **Abdourahim :** Tables users, sessions
- **Olama :** Tables requests, attachments
- **Habiba :** Table notifications

**Jeudi :**
- **Abdourahim :** Écrans Profile, AdminUserManagement
- **Olama :** Écrans MyRequests, RequestDetails
- **Habiba :** Écrans History, Notifications

**Vendredi :**
- **Tous :** Tests unitaires des services
- **Tous :** Tests PostgreSQL
- **Tous :** Documentation des API

**Livrables :**
- Services complets et testés
- Tables PostgreSQL finalisées
- Écrans principaux fonctionnels
- Documentation des API

### Semaine 3 — Intégration

**Objectif :** Connexion des modules et tests croisés

**Lundi :**
- **Tous :** Intégration écrans avec serveur TCP
- **Abdourahim + Olama :** Tests authentification → demandes
- **Olama + Habiba :** Tests demandes → notifications

**Mardi :**
- **Abdourahim + Habiba :** Tests authentification → notifications
- **Tous :** Upload de fichiers fonctionnel
- **Tous :** Notifications temps réel

**Mercredi :**
- **Tous :** Revue croisée du code (rotation)
- Abdourahim review Olama et Habiba
- Olama review Abdourahim et Habiba
- Habiba review Abdourahim et Olama

**Jeudi :**
- **Tous :** Corrections suite à revue
- **Tous :** Tests de connexions simultanées (5-10 clients)
- **Tous :** Tests Wireshark collectifs

**Vendredi :**
- **Tous :** Finalisation intégration
- **Tous :** Documentation interne
- **Tous :** Préparation tests semaine 4

**Livrables :**
- Modules intégrés
- Tests croisés validés
- Code revu et corrigé
- Documentation interne

### Semaine 4 — Validation et Démonstration

**Objectif :** MVP intégré et démontrable

**Lundi :**
- **Tous :** Tests fonctionnels complets
- **Tous :** Tests de sécurité
- **Tous :** Tests de transitions de statut

**Mardi :**
- **Tous :** Tests de déconnexion/reconnexion
- **Tous :** Tests de récupération notifications
- **Tous :** Analyse Wireshark (collectif)

**Mercredi :**
- **Tous :** Tests de charge (20-30 utilisateurs)
- **Tous :** Tests de fonctionnement sans Internet
- **Tous :** Documentation finale

**Jeudi :**
- **Tous :** Préparation démonstration
- **Tous :** Répétition scénario complet
- **Tous :** Vérification critères de validation

**Vendredi :**
- **Tous :** Démonstration finale
- **Tous :** Bilan du projet
- **Tous :** Retour d'expérience

**Livrables :**
- MVP intégré et testé
- Documentation finale
- Démonstration réussie
- Bilan de projet

---

## 11. Critères de Validation du MVP

### 11.1. Critères fonctionnels globaux

- [ ] Un étudiant peut se connecter, soumettre une demande et suivre son évolution
- [ ] Un agent peut se connecter, voir les demandes de son service et les traiter
- [ ] Un administrateur peut se connecter et gérer les comptes
- [ ] Les notifications sont reçues en temps réel
- [ ] Les pièces jointes peuvent être uploadées et téléchargées
- [ ] L'historique est complet et consultable

### 11.2. Critères techniques

- [ ] Le framing TCP fonctionne correctement (messages fragmentés/regroupés)
- [ ] Les requêtes et réponses respectent le format JSON défini
- [ ] Les transactions PostgreSQL sont atomiques
- [ ] Les mots de passe sont hachés avec bcrypt
- [ ] Les tokens de session sont uniques et imprévisibles
- [ ] Les fichiers sont vérifiés avec SHA-256
- [ ] Le code gère les erreurs sans planter

### 11.3. Critères d'intégration

- [ ] Les trois modules fonctionnent ensemble
- [ ] Les permissions sont correctement vérifiées
- [ ] Les notifications sont ciblées par utilisateur
- [ ] Les tests Wireshark montrent des communications correctes
- [ ] Le système supporte plusieurs clients simultanés

### 11.4. Critères pédagogiques

- [ ] Chaque membre peut expliquer son module
- [ ] Chaque membre peut expliquer les modules des autres
- [ ] Chaque membre peut modifier du code d'un autre module
- [ ] Chaque membre a participé aux tests TCP collectifs
- [ ] Chaque membre a participé à la revue croisée

### 11.5. Critères de démonstration

**Scénario de démonstration :**

1. Un étudiant se connecte
2. Il soumet une demande d'attestation de scolarité
3. Il ajoute une pièce justificative
4. Un agent du service de scolarité se connecte
5. Il consulte la demande et la prend en charge
6. Il approuve la demande
7. L'étudiant reçoit la notification en temps réel
8. L'étudiant consulte l'état actualisé et l'historique
9. Une déconnexion/reconnexion est testée
10. Une coupure Internet est simulée (LAN fonctionnel)

**Validation :**
- [ ] Le scénario complet fonctionne sans erreur
- [ ] Les temps de réponse sont acceptables (< 500ms pour 90% des requêtes)
- [ ] L'interface est intuitive
- [ ] Les messages d'erreur sont clairs

---

## 12. Communication et Coordination

### 12.1. Réunions hebdomadaires

**Lundi matin (30 min) :**
- Objectifs de la semaine
- Répartition des tâches
- Questions sur la documentation

**Mercredi midi (30 min) :**
- Point d'étape
- Problèmes rencontrés
- Ajustements si nécessaires

**Vendredi après-midi (1 heure) :**
- Bilan de la semaine
- Validation des livrables
- Préparation de la semaine suivante

### 12.2. Communication quotidienne

**Canal de communication :**
- Discord ou WhatsApp groupe
- Partage rapide des problèmes
- Demande d'aide si bloqué

**Règles :**
- Signaler rapidement les blocages
- Partager les solutions trouvées
- Documenter les décisions prises

### 12.3. Gestion des conflits

**En cas de désaccord technique :**
- Discuter collectivement
- Consulter le README FINAL.md
- Prendre une décision par vote si nécessaire
- Documenter la décision

**En cas de conflit de code :**
- Revue croisée pour identifier le problème
- Discuter des solutions
- Choisir la solution la plus maintenable

---

## 13. Outils et Ressources

### 13.1. Outils de développement

**IDE :**
- VS Code ou IntelliJ IDEA (choix individuel)
- Extensions Flutter/Dart

**Git :**
- GitHub pour le dépôt
- GitHub Actions pour CI (optionnel)

**Base de données :**
- PostgreSQL installé localement ou sur serveur dédié
- pgAdmin ou DBeaver pour l'administration

**Tests réseau :**
- Wireshark pour capture et analyse
- Postman ou équivalent pour tests TCP

### 13.2. Documentation de référence

**Documents du projet :**
- README FINAL.md : spécification technique
- DOCUMENTATION_ABDOURAHIM.md : guide Abdourahim
- DOCUMENTATION_OLAMA.md : guide Olama
- DOCUMENTATION_HABIBA.md : guide Habiba
- ORGANISATION_TECHNIQUE_EQUIPE.md : ce document

**Documentation externe :**
- Flutter : https://flutter.dev/docs
- Dart : https://dart.dev/guides
- PostgreSQL : https://www.postgresql.org/docs/

---

## 14. Checklist de Démarrage du Projet

Avant de commencer le développement, l'équipe doit vérifier collectivement :

### 14.1. Environnement technique

- [ ] Flutter installé sur les 3 postes
- [ ] Dart installé sur les 3 postes
- [ ] PostgreSQL installé et accessible
- [ ] Git installé et configuré sur les 3 postes
- [ ] IDE configuré sur les 3 postes
- [ ] Wireshark installé

### 14.2. Compréhension du projet

- [ ] Chaque membre a lu le README FINAL.md
- [ ] Chaque membre a lu sa documentation individuelle
- [ ] Chaque membre a lu ce document
- [ ] L'architecture est comprise par tous
- [ ] Le protocole TCP est compris par tous
- [ ] Les rôles de chacun sont clairs

### 14.3. Organisation

- [ ] Dépôt GitHub créé
- [ ] Branches initialisées (main, dev)
- [ ] Canaux de communication créés
- [ ] Calendrier des réunions défini
- [ ] Lieu de travail défini (physique ou virtuel)

### 14.4. Première réunion

- [ ] Présentation du projet
- [ ] Présentation de l'architecture
- [ ] Répartition des tâches semaine 1
- [ ] Questions/réponses
- [ ] Lancement du développement

---

## 15. Conclusion

Cette organisation technique vise à :

1. **Garantir la polyvalence** de chaque membre en Flutter, Dart, TCP et PostgreSQL
2. **Assurer l'équilibre** de la charge de travail entre Abdourahim, Olama et Habiba
3. **Faciliter l'intégration** par des interfaces claires et des conventions communes
4. **Permettre la collaboration** par des activités collectives et des revues croisées
5. **Assurer la qualité** par des tests progressifs et une validation rigoureuse

Le succès du projet dépend de la communication, de la collaboration et du respect de cette organisation technique.

**Bonne chance à l'équipe !**

---

**Document rédigé pour l'équipe N.O.H. CloudMesh — Organisation Technique**

**Ce document constitue la référence pour l'organisation technique du projet.**
