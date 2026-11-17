# DOCUMENTATION ABDOURAHIM — Authentification et Gestion des Utilisateurs

**Projet :** N.O.H. CloudMesh  
**Module principal :** Authentification et gestion des utilisateurs  
**Responsable :** Abdourahim

---

## 1. Rôle dans le projet

Abdourahim assure principalement le suivi du module d'authentification et de gestion des utilisateurs. Ce module constitue le point d'entrée de l'application : aucun utilisateur ne peut accéder aux fonctionnalités sans s'authentifier.

Ce rôle implique :
- La conception et le développement des interfaces de connexion et de gestion de profils
- L'implémentation de la logique d'authentification côté serveur
- La gestion des sessions et des jetons de sécurité
- Le contrôle des accès basé sur les rôles
- La participation à la conception du schéma de base de données

**Important :** Abdourahim ne se limite pas à ce module. Il participe également au développement Flutter global, au serveur Dart, aux tests TCP et à PostgreSQL.

---

## 2. Module principal : Authentification et Gestion des Utilisateurs

### 2.1. Objectif du module

Permettre aux utilisateurs de s'identifier de manière sécurisée, de gérer leur profil et d'accéder aux fonctionnalités selon leur rôle (étudiant, agent, administrateur).

### 2.2. Fonctionnalités principales

- Connexion avec identifiant et mot de passe
- Déconnexion
- Gestion du profil utilisateur (consultation et modification)
- Création de comptes (administrateur uniquement)
- Désactivation de comptes (administrateur uniquement)
- Attribution de rôles (administrateur uniquement)
- Gestion des sessions (expiration, renouvellement)
- Verrouillage de compte après tentatives échouées

### 2.3. Types d'utilisateurs

- **Étudiant :** Soumet et suit ses demandes
- **Agent :** Traite les demandes de son service
- **Administrateur :** Gère les comptes, les services et les agents

---

## 3. Tâches Frontend avec Flutter

### 3.1. Écrans à développer

#### Écran de connexion (LoginScreen)

**Objectif :** Permettre à un utilisateur de s'authentifier.

**Notions à comprendre :**
- Widgets Flutter de base (TextField, Button, Form)
- Validation de formulaires
- Gestion d'état (StatefulWidget ou Provider)
- Communication asynchrone avec Future

**Technologies :**
- Flutter
- Dart async/await

**Étapes de réalisation :**
1. Créer un formulaire avec deux champs (username, password)
2. Ajouter un bouton de connexion
3. Implémenter la validation des champs (non vides)
4. Créer une méthode `_login()` qui envoie une requête TCP au serveur
5. Afficher un indicateur de chargement pendant la requête
6. Gérer les erreurs (identifiants incorrects, serveur indisponible)
7. En cas de succès, stocker le token et naviguer vers l'écran approprié

**Résultat attendu :**
- Un formulaire fonctionnel qui authentifie l'utilisateur
- Affichage clair des erreurs
- Navigation automatique après connexion réussie

**Tests :**
- Tester avec des identifiants valides
- Tester avec des identifiants invalides
- Tester avec des champs vides
- Tester lorsque le serveur est éteint

**Erreurs fréquentes à éviter :**
- Ne pas masquer le mot de passe (utiliser `obscureText: true`)
- Ne pas gérer les erreurs réseau
- Bloquer l'interface pendant la requête sans indicateur

#### Écran de profil (ProfileScreen)

**Objectif :** Permettre à l'utilisateur de consulter et modifier ses informations.

**Notions à comprendre :**
- Affichage de données depuis une réponse serveur
- Mise à jour de données
- Confirmation avant modification

**Étapes de réalisation :**
1. Afficher les informations de l'utilisateur (nom, email, rôle)
2. Ajouter un formulaire de modification (champs modifiables)
3. Implémenter la méthode de mise à jour via TCP
4. Ajouter une confirmation avant sauvegarde
5. Afficher un message de succès ou d'erreur

**Tests :**
- Modifier des informations valides
- Tenter de modifier avec des données invalides

#### Écran de gestion des utilisateurs (AdminUserManagementScreen)

**Objectif :** Permettre à l'administrateur de créer et gérer les comptes.

**Notions à comprendre :**
- Listes et ListView
- Dialogs de confirmation
- Actions administratives

**Étapes de réalisation :**
1. Afficher la liste des utilisateurs existants
2. Ajouter un bouton pour créer un nouvel utilisateur
3. Créer un formulaire de création (username, password, rôle)
4. Implémenter la création via TCP
5. Ajouter des boutons pour désactiver/supprimer des comptes
6. Demander confirmation avant action

**Tests :**
- Créer un utilisateur avec chaque rôle
- Tenter de créer un utilisateur avec un nom existant
- Désactiver un compte

### 3.2. Widgets réutilisables à créer

- `LoginForm` : Formulaire de connexion réutilisable
- `ProfileForm` : Formulaire de profil
- `UserCard` : Carte d'affichage d'un utilisateur (pour l'admin)

---

## 4. Tâches Backend avec Dart

### 4.1. Service d'authentification (AuthService)

**Objectif :** Gérer la logique d'authentification côté serveur.

**Notions à comprendre :**
- Hachage de mots de passe (bcrypt)
- Génération de jetons aléatoires
- Validation d'identifiants
- Gestion des erreurs

**Technologies :**
- Dart
- Package `bcrypt` pour le hachage
- Package `crypto` pour la génération de tokens
- PostgreSQL (via driver)

**Étapes de réalisation :**

#### Étape 1 : Hachage des mots de passe

```dart
// Exemple de structure
String hashPassword(String password) {
  // Utiliser bcrypt avec un salt
  final salt = bcrypt.gensalt();
  return bcrypt.hashpw(password, salt);
}

bool verifyPassword(String password, String hashedPassword) {
  return bcrypt.checkpw(password, hashedPassword);
}
```

#### Étape 2 : Génération de jeton de session

```dart
String generateSessionToken() {
  // Générer un token aléatoire de 32 octets
  final bytes = crypto.Random.secure().bytes(32);
  return base64.encode(bytes);
}
```

#### Étape 3 : Méthode d'authentification

```dart
Future<Map<String, dynamic>> login(String username, String password) async {
  // 1. Rechercher l'utilisateur dans PostgreSQL
  // 2. Vérifier que le compte n'est pas verrouillé
  // 3. Vérifier le mot de passe
  // 4. Si OK : générer un token, créer une session, retourner token et user
  // 5. Si KO : incrémenter compteur échecs, verrouiller si > 5
}
```

#### Étape 4 : Méthode de déconnexion

```dart
Future<void> logout(String token) async {
  // 1. Marquer la session comme inactive dans PostgreSQL
  // 2. Supprimer le token du cache si utilisé
}
```

**Résultat attendu :**
- Un service capable d'authentifier les utilisateurs
- Gestion sécurisée des mots de passe
- Création et invalidation de sessions

**Tests :**
- Authentifier avec des identifiants valides
- Authentifier avec des identifiants invalides
- Tester le verrouillage après 5 échecs
- Vérifier que le token est unique

**Erreurs fréquentes à éviter :**
- Stocker les mots de passe en clair
- Générer des tokens prévisibles
- Ne pas vérifier le verrouillage de compte

### 4.2. Service de gestion des utilisateurs (UserService)

**Objectif :** Gérer les opérations CRUD sur les utilisateurs.

**Étapes de réalisation :**

#### Étape 1 : Création d'utilisateur

```dart
Future<User> createUser({
  required String username,
  required String password,
  required String role,
}) async {
  // 1. Vérifier que le username n'existe pas déjà
  // 2. Hacher le mot de passe
  // 3. Insérer dans PostgreSQL
  // 4. Retourner l'utilisateur créé
}
```

#### Étape 2 : Modification de profil

```dart
Future<void> updateProfile(int userId, Map<String, dynamic> updates) async {
  // 1. Valider les données
  // 2. Mettre à jour dans PostgreSQL
}
```

#### Étape 3 : Désactivation de compte

```dart
Future<void> deactivateUser(int userId) async {
  // 1. Marquer le compte comme inactif
  // 2. Invalider toutes les sessions actives
}
```

### 4.3. Service de gestion des sessions (SessionService)

**Objectif :** Gérer le cycle de vie des sessions.

**Fonctionnalités :**
- Créer une session après authentification
- Vérifier la validité d'un token
- Renouveler un token (à 50% de sa durée de vie)
- Nettoyer les sessions expirées
- Limiter à 1 session active par utilisateur

**Étapes de réalisation :**

```dart
Future<Session> createSession(int userId, String role) async {
  // 1. Générer un token unique
  // 2. Définir la date d'expiration (30min ou 2h selon le rôle)
  // 3. Invalider les sessions existantes de cet utilisateur
  // 4. Insérer la nouvelle session dans PostgreSQL
  // 5. Retourner la session
}

Future<bool> validateToken(String token) async {
  // 1. Rechercher la session par token
  // 2. Vérifier qu'elle existe et n'est pas expirée
  // 3. Retourner true/false
}
```

---

## 5. Interactions TCP Nécessaires

### 5.1. Opérations du protocole

Abdourahim doit implémenter les actions TCP suivantes côté serveur et client :

#### LOGIN

**Requête client :**
```json
{
  "request_id": "req-001",
  "type": "REQUEST",
  "action": "LOGIN",
  "payload": {
    "username": "etudiant01",
    "password": "mot_de_passe"
  }
}
```

**Réponse serveur (succès) :**
```json
{
  "request_id": "req-001",
  "status": "SUCCESS",
  "data": {
    "token": "generated-session-token",
    "user": {
      "id": 15,
      "username": "etudiant01",
      "role": "STUDENT"
    }
  },
  "error": null
}
```

**Réponse serveur (erreur) :**
```json
{
  "request_id": "req-001",
  "status": "ERROR",
  "data": null,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Identifiants incorrects"
  }
}
```

#### LOGOUT

**Requête client :**
```json
{
  "request_id": "req-002",
  "type": "REQUEST",
  "action": "LOGOUT",
  "token": "session-token",
  "payload": {}
}
```

#### CREATE_USER (administrateur uniquement)

**Requête client :**
```json
{
  "request_id": "req-003",
  "type": "REQUEST",
  "action": "CREATE_USER",
  "token": "admin-token",
  "payload": {
    "username": "agent01",
    "password": "secure_password",
    "role": "AGENT"
  }
}
```

#### UPDATE_PROFILE

**Requête client :**
```json
{
  "request_id": "req-004",
  "type": "REQUEST",
  "action": "UPDATE_PROFILE",
  "token": "session-token",
  "payload": {
    "email": "nouveau.email@example.com"
  }
}
```

### 5.2. Implémentation côté client

**Objectif :** Créer un client TCP capable d'envoyer ces requêtes.

**Notions à comprendre :**
- Classe `Socket` de Dart
- Encodage/décodage JSON
- Framing (préfixe 4 octets)
- Gestion asynchrone

**Étapes de réalisation :**

#### Étape 1 : Créer une classe TcpClient

```dart
class TcpClient {
  late Socket _socket;
  
  Future<void> connect(String host, int port) async {
    _socket = await Socket.connect(host, port);
  }
  
  Future<Map<String, dynamic>> sendRequest(Map<String, dynamic> request) async {
    // 1. Sérialiser en JSON
    // 2. Ajouter le préfixe de taille
    // 3. Envoyer via _socket
    // 4. Lire la réponse
    // 5. Décoder et retourner
  }
}
```

#### Étape 2 : Implémenter le framing

```dart
List<int> frameMessage(String jsonMessage) {
  final bytes = utf8.encode(jsonMessage);
  final lengthPrefix = ByteData(4)..setUint32(0, bytes.length, Endian.big);
  return [...lengthPrefix.buffer.asUint8List(), ...bytes];
}
```

**Tests :**
- Tester la connexion au serveur
- Tester l'envoi d'une requête LOGIN
- Tester la réception d'une réponse
- Tester avec un serveur éteint

### 5.3. Implémentation côté serveur

**Objectif :** Créer un gestionnaire de requêtes pour ces actions.

**Étapes de réalisation :**

```dart
void handleRequest(Map<String, dynamic> request, Socket socket) {
  final action = request['action'];
  
  switch (action) {
    case 'LOGIN':
      handleLogin(request, socket);
      break;
    case 'LOGOUT':
      handleLogout(request, socket);
      break;
    case 'CREATE_USER':
      handleCreateUser(request, socket);
      break;
    // ...
  }
}
```

---

## 6. Opérations PostgreSQL Concernées

### 6.1. Tables à concevoir

#### Table `users`

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(100),
  role VARCHAR(20) NOT NULL CHECK (role IN ('STUDENT', 'AGENT', 'ADMIN')),
  is_active BOOLEAN DEFAULT true,
  failed_login_attempts INTEGER DEFAULT 0,
  locked_until TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Responsabilités :**
- Abdourahim conçoit cette table
- Il définit les contraintes et index
- Il écrit les requêtes SQL pour les opérations CRUD

#### Table `sessions`

```sql
CREATE TABLE sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sessions_token ON sessions(token);
CREATE INDEX idx_sessions_user ON sessions(user_id);
```

### 6.2. Requêtes SQL principales

#### Recherche d'utilisateur par username

```sql
SELECT id, username, password_hash, role, is_active, failed_login_attempts, locked_until
FROM users
WHERE username = $1;
```

#### Création d'utilisateur

```sql
INSERT INTO users (username, password_hash, email, role)
VALUES ($1, $2, $3, $4)
RETURNING id, username, role;
```

#### Incrémenter les tentatives échouées

```sql
UPDATE users
SET failed_login_attempts = failed_login_attempts + 1
WHERE id = $1;
```

#### Verrouiller un compte

```sql
UPDATE users
SET locked_until = CURRENT_TIMESTAMP + INTERVAL '15 minutes',
    failed_login_attempts = 0
WHERE id = $1;
```

#### Créer une session

```sql
INSERT INTO sessions (user_id, token, expires_at)
VALUES ($1, $2, $3)
RETURNING id, token, expires_at;
```

#### Valider un token

```sql
SELECT s.id, s.user_id, u.username, u.role
FROM sessions s
JOIN users u ON s.user_id = u.id
WHERE s.token = $1
  AND s.expires_at > CURRENT_TIMESTAMP
  AND u.is_active = true;
```

---

## 7. Compétences Techniques à Acquérir

### 7.1. Dart et Flutter

- **Widgets Flutter :** TextField, Button, Form, ListView, Dialog
- **Gestion d'état :** StatefulWidget, setState, Provider
- **Navigation :** Navigator, Routes
- **Asynchrone :** Future, async/await, Stream
- **Validation de formulaires**

### 7.2. Communication TCP

- **Classe Socket :** connexion, envoi, réception
- **Framing :** préfixe de taille, Big Endian
- **JSON :** encodage, décodage
- **Gestion des erreurs réseau**

### 7.3. PostgreSQL

- **Driver PostgreSQL pour Dart :** `postgres` package
- **Requêtes SQL :** SELECT, INSERT, UPDATE, DELETE
- **Transactions :** BEGIN, COMMIT, ROLLBACK
- **Paramètres :** protection contre injection SQL
- **Index et contraintes**

### 7.4. Sécurité

- **Hachage de mots de passe :** bcrypt
- **Génération de tokens aléatoires**
- **Validation d'entrées**
- **Gestion des erreurs sans exposer d'informations sensibles**

### 7.5. Git et GitHub

- **Commandes de base :** add, commit, push, pull
- **Branches :** création, fusion, résolution de conflits
- **Pull requests :** review et merge

---

## 8. Collaboration avec Olama et Habiba

### 8.1. Dépendances avec le module d'Olama (Gestion des demandes)

**Ce que le module d'authentification fournit à Olama :**
- Le jeton de session pour chaque requête protégée
- Les informations de l'utilisateur connecté (id, rôle)
- La validation des permissions avant traitement d'une demande

**Ce qu'Abdourahim doit fournir à Olama :**
- Une fonction `validateToken(token)` qui retourne les infos utilisateur
- Une fonction `checkPermission(userId, action)` pour vérifier les droits
- La structure de la table `users` avec le champ `role`

**Collaboration :**
- Semaine 1 : Définir ensemble le format des tokens et la table users
- Semaine 2 : Abdourahim fournit l'API de validation à Olama
- Semaine 3 : Tests intégrés : Olama teste ses requêtes avec les tokens d'Abdourahim

### 8.2. Dépendances avec le module d'Habiba (Suivi et notifications)

**Ce que le module d'authentification fournit à Habiba :**
- Le jeton de session pour les requêtes de notifications
- Les informations utilisateur pour cibler les notifications
- La validation que l'utilisateur a le droit de consulter un historique

**Ce qu'Abdourahim doit fournir à Habiba :**
- La même fonction `validateToken(token)`
- Une fonction `getUserById(userId)` pour récupérer les infos
- La structure de la table `sessions` pour gérer les connexions actives

**Collaboration :**
- Semaine 1 : Définir ensemble comment les notifications seront liées aux utilisateurs
- Semaine 2 : Abdourahim fournit l'API utilisateur à Habiba
- Semaine 3 : Tests intégrés : Habiba teste les notifications avec les sessions d'Abdourahim

### 8.3. Activités collectives

**Tests TCP (tous les membres) :**
- Abdourahim participe aux tests de framing avec Olama et Habiba
- Il utilise Wireshark pour vérifier les messages LOGIN/LOGOUT
- Il teste les connexions simultanées avec les autres

**Intégration :**
- Semaine 3 : Revue croisée du code
- Abdourahim examine le code d'Olama et Habiba
- Olama et Habiba examinent le code d'Abdourahim
- Corrections collectives des incohérences

---

## 9. Livrables Attendus

### 9.1. Livrables Semaine 1

- [ ] Prototype de formulaire de connexion Flutter
- [ ] Prototype de client TCP capable d'envoyer LOGIN
- [ ] Prototype de serveur TCP capable de traiter LOGIN
- [ ] Première version de la table `users` en SQL
- [ ] Documentation du framing TCP

### 9.2. Livrables Semaine 2

- [ ] Écran de connexion fonctionnel complet
- [ ] Écran de profil utilisateur
- [ ] Écran de gestion des utilisateurs (admin)
- [ ] Service AuthService complet (hachage, tokens, sessions)
- [ ] Service UserService complet
- [ ] Service SessionService complet
- [ ] Tables `users` et `sessions` finalisées
- [ ] Tests unitaires des services

### 9.3. Livrables Semaine 3

- [ ] Intégration des écrans avec le serveur
- [ ] Tests d'authentification avec Olama et Habiba
- [ ] Validation des permissions pour les modules des autres
- [ ] Corrections suite à la revue croisée
- [ ] Documentation des API internes

### 9.4. Livrables Semaine 4

- [ ] Tests fonctionnels complets du module
- [ ] Tests de sécurité (verrouillage, sessions)
- [ ] Tests de connexions simultanées
- [ ] Documentation finale du module
- [ ] Participation à la démonstration globale

---

## 10. Critères de Validation

### 10.1. Critères fonctionnels

- [ ] Un utilisateur peut se connecter avec des identifiants valides
- [ ] Un utilisateur ne peut pas se connecter avec des identifiants invalides
- [ ] Après 5 tentatives échouées, le compte est verrouillé 15 minutes
- [ ] Un utilisateur peut se déconnecter
- [ ] La session expire après 30 minutes (étudiant) ou 2 heures (agent/admin)
- [ ] Un administrateur peut créer un compte
- [ ] Un administrateur peut désactiver un compte
- [ ] Un utilisateur peut modifier son profil
- [ ] Un utilisateur ne peut voir que son propre profil
- [ ] Les mots de passe sont hachés et jamais stockés en clair

### 10.2. Critères techniques

- [ ] Les requêtes TCP respectent le format défini (JSON + préfixe)
- [ ] Les réponses TCP incluent toujours request_id, status, data, error
- [ ] Les tokens sont uniques et imprévisibles
- [ ] La table `users` respecte le schéma défini
- [ ] La table `sessions` respecte le schéma défini
- [ ] Les requêtes SQL utilisent des paramètres (pas de concaténation)
- [ ] Le code gère les erreurs réseau sans planter
- [ ] Le code gère les erreurs SQL sans planter

### 10.3. Critères d'intégration

- [ ] Olama peut utiliser le token d'Abdourahim pour ses requêtes
- [ ] Habiba peut utiliser le token d'Abdourahim pour ses requêtes
- [ ] Les permissions sont correctement vérifiées
- [ ] Les tests Wireshark montrent des messages correctement framés
- [ ] Le module fonctionne avec plusieurs clients connectés

### 10.4. Critères pédagogiques

- [ ] Abdourahim peut expliquer le fonctionnement du hachage bcrypt
- [ ] Abdourahim peut expliquer le mécanisme de framing TCP
- [ ] Abdourahim peut expliquer la structure des tables users/sessions
- [ ] Abdourahim peut modifier le code d'Olama ou Habiba si nécessaire
- [ ] Abdourahim a participé aux tests TCP collectifs

---

## 11. Calendrier Détaillé

### Semaine 1 — Fondations

**Lundi :**
- Apprentissage Flutter : widgets de base, formulaires
- Apprentissage Dart Socket : connexion basique

**Mardi :**
- Conception de la table `users` avec Olama et Habiba
- Prototype écran de connexion

**Mercredi :**
- Prototype client TCP (envoi LOGIN)
- Prototype serveur TCP (réception LOGIN)

**Jeudi :**
- Implémentation du framing (préfixe 4 octets)
- Tests avec Wireshark (collectif)

**Vendredi :**
- Intégration prototype client-serveur
- Documentation du framing

### Semaine 2 — Développement

**Lundi :**
- Implémentation AuthService (hachage bcrypt)
- Implémentation génération de tokens

**Mardi :**
- Implémentation SessionService
- Création table `sessions`

**Mercredi :**
- Implémentation UserService
- Écran de profil

**Jeudi :**
- Écran de gestion utilisateurs (admin)
- Tests unitaires des services

**Vendredi :**
- Tests d'intégration avec PostgreSQL
- Documentation des API

### Semaine 3 — Intégration

**Lundi :**
- Intégration écrans avec serveur TCP
- Tests avec Olama (permissions)

**Mardi :**
- Tests avec Habiba (notifications)
- Corrections bugs

**Mercredi :**
- Revue croisée du code (Abdourahim examine Olama et Habiba)
- Revue croisée inverse

**Jeudi :**
- Corrections suite à revue
- Tests de connexions simultanées (collectif)

**Vendredi :**
- Finalisation intégration
- Documentation interne

### Semaine 4 — Validation

**Lundi :**
- Tests fonctionnels complets
- Tests de sécurité

**Mardi :**
- Tests de déconnexion/reconnexion (collectif)
- Analyse Wireshark (collectif)

**Mercredi :**
- Tests de charge (50 connexions)
- Documentation finale

**Jeudi :**
- Préparation démonstration
- Répétition scénario

**Vendredi :**
- Démonstration finale
- Bilan

---

## 12. Ressources et Références

### Documentation Flutter
- https://flutter.dev/docs
- Widgets catalog : https://flutter.dev/docs/development/ui/widgets

### Documentation Dart
- https://dart.dev/guides
- Async programming : https://dart.dev/guides/language/language-tour#asynchrony

### Communication TCP
- Dart Socket : https://api.dart.dev/stable/dart-io/Socket-class.html
- TCP/IP : concepts de base

### PostgreSQL
- Documentation officielle : https://www.postgresql.org/docs/
- Package Dart postgres : https://pub.dev/packages/postgres

### Sécurité
- bcrypt : https://pub.dev/packages/bcrypt
- crypto : https://pub.dev/packages/crypto

---

## 13. Checklist de Démarrage

Avant de commencer le développement, vérifier :

- [ ] Flutter installé et fonctionnel
- [ ] Dart installé et fonctionnel
- [ ] PostgreSQL installé et accessible
- [ ] Compréhension du README FINAL.md
- [ ] Compréhension du protocole TCP défini
- [ ] Compréhension des tables PostgreSQL à créer
- [ ] Environnement Git configuré
- [ ] IDE configuré (VS Code ou IntelliJ)

---

**Document rédigé pour Abdourahim — Module Authentification et Gestion des Utilisateurs**

**Ce document constitue un guide de travail. N'hésitez pas à solliciter l'équipe pour clarifications et adaptations.**
