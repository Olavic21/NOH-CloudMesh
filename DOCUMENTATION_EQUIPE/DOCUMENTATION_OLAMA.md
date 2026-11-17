# DOCUMENTATION OLAMA — Gestion des Demandes Administratives

**Projet :** N.O.H. CloudMesh  
**Module principal :** Gestion des demandes administratives  
**Responsable :** Olama

---

## 1. Rôle dans le projet

Olama assure principalement le suivi du module de gestion des demandes administratives. Ce module constitue le cœur fonctionnel de l'application : c'est là que les étudiants soumettent leurs demandes et que les agents les traitent.

Ce rôle implique :
- La conception et le développement des interfaces de soumission et de consultation des demandes
- L'implémentation de la logique de traitement des demandes côté serveur
- La gestion des pièces jointes
- La gestion des statuts et des transitions
- La participation à la conception du schéma de base de données

**Important :** Olama ne se limite pas à ce module. Il participe également au développement Flutter global, au serveur Dart, aux tests TCP et à PostgreSQL.

---

## 2. Module principal : Gestion des Demandes Administratives

### 2.1. Objectif du module

Permettre aux étudiants de soumettre des demandes administratives (attestations, certificats, relevés de notes, réclamations) et aux agents de les traiter selon leur service.

### 2.2. Fonctionnalités principales

- Soumission d'une demande par un étudiant
- Consultation de ses propres demandes (étudiant)
- Consultation des demandes du service (agent)
- Modification du statut d'une demande (agent)
- Ajout de commentaires lors du traitement
- Ajout de pièces jointes
- Téléchargement des pièces jointes
- Consultation des détails d'une demande

### 2.3. Types de demandes

- **Attestation de scolarité**
- **Certificat de scolarité**
- **Relevé de notes**
- **Réclamation administrative**

### 2.4. Statuts des demandes

- `SUBMITTED` : Demande soumise
- `IN_REVIEW` : En cours de traitement
- `NEEDS_INFO` : Informations complémentaires requises
- `APPROVED` : Demande approuvée
- `REJECTED` : Demande rejetée

---

## 3. Tâches Frontend avec Flutter

### 3.1. Écrans à développer

#### Écran de nouvelle demande (NewRequestScreen)

**Objectif :** Permettre à un étudiant de soumettre une nouvelle demande.

**Notions à comprendre :**
- Formulaires complexes avec plusieurs champs
- Sélecteurs (Dropdown)
- Upload de fichiers
- Validation multi-champs

**Technologies :**
- Flutter
- `file_picker` package pour la sélection de fichiers
- Gestion d'état

**Étapes de réalisation :**

1. Créer un formulaire avec les champs nécessaires :
   - Type de demande (dropdown)
   - Description (textarea)
   - Pièces jointes (optionnel)

2. Implémenter la sélection de fichiers :
   - Bouton "Ajouter une pièce jointe"
   - Utiliser `file_picker` pour choisir un fichier
   - Afficher le nom du fichier sélectionné
   - Limiter à 5 Mo par fichier

3. Implémenter la validation :
   - Type de demande obligatoire
   - Description obligatoire
   - Fichier : formats acceptés (PDF, JPG, PNG)

4. Créer une méthode `_submitRequest()` :
   - Envoyer d'abord les métadonnées de la demande via TCP
   - Si succès, envoyer les fichiers par blocs
   - Afficher un indicateur de progression

5. Gérer les erreurs :
   - Fichier trop volumineux
   - Format non accepté
   - Erreur serveur

**Résultat attendu :**
- Un formulaire fonctionnel qui soumet une demande
- Upload de fichiers avec indicateur de progression
- Affichage clair des erreurs
- Navigation vers "Mes demandes" après succès

**Tests :**
- Soumettre une demande sans fichier
- Soumettre une demande avec un fichier PDF
- Tenter d'envoyer un fichier trop volumineux
- Tenter d'envoyer un fichier non accepté
- Tester avec des champs vides

**Erreurs fréquentes à éviter :**
- Ne pas valider la taille du fichier avant envoi
- Ne pas afficher la progression pendant l'upload
- Bloquer l'interface pendant l'upload sans indicateur
- Envoyer le fichier sans vérifier que la demande a été créée

#### Écran "Mes demandes" (MyRequestsScreen)

**Objectif :** Permettre à un étudiant de consulter ses demandes.

**Notions à comprendre :**
- ListView et ListTile
- Récupération de données depuis le serveur
- Rafraîchissement (pull-to-refresh)
- Filtres et tri

**Étapes de réalisation :**

1. Créer une méthode `_fetchMyRequests()` :
   - Envoyer une requête TCP `GET_MY_REQUESTS`
   - Parser la réponse JSON
   - Stocker dans une liste

2. Afficher la liste avec ListView :
   - Chaque élément affiche : type, statut, date
   - Code couleur selon le statut
   - Tap sur un élément → détails

3. Implémenter pull-to-refresh :
   - Utiliser `RefreshIndicator`
   - Recharger la liste

4. Ajouter un bouton flottant (FAB) :
   - Pour créer une nouvelle demande

**Résultat attendu :**
- Liste des demandes de l'étudiant
- Rafraîchissement possible
- Navigation vers détails

**Tests :**
- Afficher une liste vide
- Afficher une liste avec plusieurs demandes
- Tester le rafraîchissement

#### Écran de détails d'une demande (RequestDetailsScreen)

**Objectif :** Afficher les détails complets d'une demande.

**Étapes de réalisation :**

1. Afficher les informations :
   - Type de demande
   - Description
   - Statut (avec badge coloré)
   - Date de soumission
   - Historique des statuts
   - Pièces jointes (avec lien de téléchargement)

2. Pour les agents uniquement :
   - Boutons pour changer le statut
   - Champ pour ajouter un commentaire
   - Formulaire de transition de statut

**Tests :**
- Consulter une demande en tant qu'étudiant
- Consulter une demande en tant qu'agent
- Vérifier que les boutons d'action n'apparaissent que pour l'agent

#### Écran de traitement des demandes (AgentRequestsScreen)

**Objectif :** Permettre à un agent de voir et traiter les demandes de son service.

**Étapes de réalisation :**

1. Filtrer par service :
   - Envoyer `GET_SERVICE_REQUESTS` avec le token
   - Le serveur filtre selon le service de l'agent

2. Afficher la liste des demandes du service

3. Permettre de prendre en charge une demande :
   - Bouton "Prendre en charge"
   - Change le statut en `IN_REVIEW`

4. Permettre de traiter une demande :
   - Choisir le nouveau statut
   - Ajouter un commentaire (obligatoire pour rejet/infos)
   - Confirmer

**Tests :**
- Vérifier que l'agent ne voit que son service
- Tester chaque transition de statut
- Tester l'ajout de commentaire

### 3.2. Widgets réutilisables à créer

- `RequestCard` : Carte d'affichage d'une demande dans une liste
- `StatusBadge` : Badge coloré selon le statut
- `FileAttachment` : Widget pour afficher une pièce jointe
- `RequestForm` : Formulaire de création de demande

---

## 4. Tâches Backend avec Dart

### 4.1. Service de gestion des demandes (RequestService)

**Objectif :** Gérer la logique de création et traitement des demandes.

**Notions à comprendre :**
- Validation des données
- Contrôle des permissions
- Gestion des transactions PostgreSQL
- Logique de transitions de statut

**Technologies :**
- Dart
- PostgreSQL (via driver)
- Validation des entrées

**Étapes de réalisation :**

#### Étape 1 : Création d'une demande

```dart
Future<Request> createRequest({
  required int userId,
  required String requestType,
  required String description,
}) async {
  // 1. Valider que l'utilisateur est un étudiant
  // 2. Valider le type de demande
  // 3. Insérer dans PostgreSQL avec statut SUBMITTED
  // 4. Créer une entrée dans l'historique
  // 5. Retourner la demande créée
}
```

#### Étape 2 : Récupération des demandes d'un utilisateur

```dart
Future<List<Request>> getUserRequests(int userId) async {
  // 1. Sélectionner les demandes où user_id = userId
  // 2. Trier par date décroissante
  // 3. Retourner la liste
}
```

#### Étape 3 : Récupération des demandes d'un service

```dart
Future<List<Request>> getServiceRequests(String service) async {
  // 1. Sélectionner les demandes du service
  // 2. Filtrer par statut si nécessaire
  // 3. Retourner la liste
}
```

#### Étape 4 : Modification du statut

```dart
Future<void> updateRequestStatus({
  required int requestId,
  required String newStatus,
  required int actorId,
  String? comment,
}) async {
  // 1. Valider que la transition est autorisée
  // 2. Vérifier que l'acteur a les permissions
  // 3. Si NEEDS_INFO ou REJECTED : commenter obligatoire
  // 4. Transaction PostgreSQL :
  //    - UPDATE requests SET status = newStatus
  //    - INSERT INTO request_history
  // 5. Notifier l'étudiant si applicable
}
```

**Résultat attendu :**
- Un service capable de créer et modifier des demandes
- Validation stricte des transitions
- Historique complet des changements

**Tests :**
- Créer une demande avec chaque type
- Tenter une transition non autorisée
- Modifier le statut sans commentaire quand requis
- Vérifier que l'historique est enregistré

**Erreurs fréquentes à éviter :**
- Ne pas valider les transitions de statut
- Ne pas vérifier les permissions
- Oublier d'enregistrer l'historique
- Ne pas utiliser de transaction (incohérence possible)

### 4.2. Service de gestion des pièces jointes (AttachmentService)

**Objectif :** Gérer le stockage et le transfert des fichiers.

**Notions à comprendre :**
- Transfert par blocs
- Calcul de checksum SHA-256
- Validation de fichiers (type, taille)
- Stockage sur système de fichiers

**Étapes de réalisation :**

#### Étape 1 : Initialisation d'un transfert

```dart
Future<String> initiateUpload({
  required int requestId,
  required String fileName,
  required int fileSize,
  required String mimeType,
}) async {
  // 1. Valider que la demande existe et appartient à l'utilisateur
  // 2. Valider la taille (< 5 Mo)
  // 3. Valider le type MIME
  // 4. Générer un nom de fichier unique
  // 5. Créer une entrée dans attachments (status = UPLOADING)
  // 6. Retourner un upload_id
}
```

#### Étape 2 : Réception d'un bloc

```dart
Future<void> uploadBlock({
  required String uploadId,
  required int blockNumber,
  required List<int> data,
}) async {
  // 1. Vérifier que l'upload existe et est en cours
  // 2. Écrire le bloc dans un fichier temporaire
  // 3. Confirmer la réception
}
```

#### Étape 3 : Finalisation d'un transfert

```dart
Future<void> finalizeUpload({
  required String uploadId,
  required String checksum,
}) async {
  // 1. Calculer le SHA-256 du fichier reçu
  // 2. Comparer avec le checksum envoyé
  // 3. Si OK : déplacer vers le stockage final
  // 4. Mettre à jour la table attachments (status = COMPLETED)
  // 5. Si KO : supprimer le fichier temporaire
}
```

#### Étape 4 : Téléchargement d'un fichier

```dart
Future<AttachmentInfo> getAttachment(int attachmentId, int userId) async {
  // 1. Récupérer les métadonnées
  // 2. Vérifier que l'utilisateur a le droit de télécharger
  // 3. Retourner le chemin du fichier
}
```

**Résultat attendu :**
- Upload par blocs fonctionnel
- Vérification d'intégrité SHA-256
- Validation des types et tailles

**Tests :**
- Uploader un fichier PDF valide
- Uploader un fichier trop volumineux
- Uploader un fichier avec un mauvais checksum
- Télécharger un fichier autorisé
- Tenter de télécharger un fichier non autorisé

---

## 5. Interactions TCP Nécessaires

### 5.1. Opérations du protocole

Olama doit implémenter les actions TCP suivantes :

#### SUBMIT_REQUEST

**Requête client :**
```json
{
  "request_id": "req-001",
  "type": "REQUEST",
  "action": "SUBMIT_REQUEST",
  "token": "student-token",
  "payload": {
    "request_type": "ATTESTATION_SCOLARITE",
    "description": "Besoin d'une attestation pour bourse"
  }
}
```

**Réponse serveur :**
```json
{
  "request_id": "req-001",
  "status": "SUCCESS",
  "data": {
    "request_id": 123,
    "status": "SUBMITTED",
    "created_at": "2026-01-15T10:30:00Z"
  },
  "error": null
}
```

#### GET_MY_REQUESTS

**Requête client :**
```json
{
  "request_id": "req-002",
  "type": "REQUEST",
  "action": "GET_MY_REQUESTS",
  "token": "student-token",
  "payload": {}
}
```

#### GET_REQUEST_DETAILS

**Requête client :**
```json
{
  "request_id": "req-003",
  "type": "REQUEST",
  "action": "GET_REQUEST_DETAILS",
  "token": "student-token",
  "payload": {
    "request_id": 123
  }
}
```

#### UPDATE_REQUEST_STATUS (agent uniquement)

**Requête client :**
```json
{
  "request_id": "req-004",
  "type": "REQUEST",
  "action": "UPDATE_REQUEST_STATUS",
  "token": "agent-token",
  "payload": {
    "request_id": 123,
    "new_status": "APPROVED",
    "comment": "Document validé"
  }
}
```

#### UPLOAD_ATTACHMENT

**Requête d'initialisation :**
```json
{
  "request_id": "req-005",
  "type": "REQUEST",
  "action": "UPLOAD_ATTACHMENT",
  "token": "student-token",
  "payload": {
    "request_id": 123,
    "file_name": "document.pdf",
    "file_size": 1048576,
    "mime_type": "application/pdf"
  }
}
```

**Réponse avec upload_id :**
```json
{
  "request_id": "req-005",
  "status": "SUCCESS",
  "data": {
    "upload_id": "up-abc123",
    "block_size": 49152
  },
  "error": null
}
```

#### DOWNLOAD_ATTACHMENT

**Requête client :**
```json
{
  "request_id": "req-006",
  "type": "REQUEST",
  "action": "DOWNLOAD_ATTACHMENT",
  "token": "student-token",
  "payload": {
    "attachment_id": 456
  }
}
```

### 5.2. Implémentation du transfert par blocs

**Objectif :** Envoyer un fichier par blocs de 48 Kio.

**Étapes de réalisation côté client :**

```dart
Future<void> uploadFile(String uploadId, File file) async {
  final bytes = await file.readAsBytes();
  final blockSize = 48 * 1024; // 48 Kio
  
  for (int i = 0; i < bytes.length; i += blockSize) {
    final end = (i + blockSize < bytes.length) ? i + blockSize : bytes.length;
    final block = bytes.sublist(i, end);
    
    await sendBlock(uploadId, i ~/ blockSize, block);
  }
  
  await finalizeUpload(uploadId, calculateChecksum(bytes));
}
```

**Tests :**
- Uploader un fichier de 1 Mo
- Uploader un fichier de 5 Mo (limite)
- Simuler une coupure réseau pendant l'upload

---

## 6. Opérations PostgreSQL Concernées

### 6.1. Tables à concevoir

#### Table `requests`

```sql
CREATE TABLE requests (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  request_type VARCHAR(50) NOT NULL CHECK (request_type IN (
    'ATTESTATION_SCOLARITE',
    'CERTIFICAT_SCOLARITE',
    'RELEVE_NOTES',
    'RECLAMATION_ADMINISTRATIVE'
  )),
  description TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'SUBMITTED' CHECK (status IN (
    'SUBMITTED', 'IN_REVIEW', 'NEEDS_INFO', 'APPROVED', 'REJECTED'
  )),
  service VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_requests_user ON requests(user_id);
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_requests_service ON requests(service);
```

**Responsabilités :**
- Olama conçoit cette table
- Il définit les contraintes et index
- Il écrit les requêtes SQL pour les opérations CRUD

#### Table `request_history`

```sql
CREATE TABLE request_history (
  id SERIAL PRIMARY KEY,
  request_id INTEGER NOT NULL REFERENCES requests(id) ON DELETE CASCADE,
  previous_status VARCHAR(20),
  new_status VARCHAR(20) NOT NULL,
  actor_id INTEGER NOT NULL REFERENCES users(id),
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_history_request ON request_history(request_id);
```

#### Table `attachments`

```sql
CREATE TABLE attachments (
  id SERIAL PRIMARY KEY,
  request_id INTEGER NOT NULL REFERENCES requests(id) ON DELETE CASCADE,
  original_name VARCHAR(255) NOT NULL,
  stored_name VARCHAR(255) NOT NULL,
  mime_type VARCHAR(100) NOT NULL,
  file_size INTEGER NOT NULL,
  storage_path VARCHAR(500) NOT NULL,
  checksum VARCHAR(64) NOT NULL,
  upload_status VARCHAR(20) DEFAULT 'UPLOADING' CHECK (upload_status IN (
    'UPLOADING', 'COMPLETED', 'FAILED'
  )),
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_attachments_request ON attachments(request_id);
```

### 6.2. Requêtes SQL principales

#### Création d'une demande

```sql
INSERT INTO requests (user_id, request_type, description, service)
VALUES ($1, $2, $3, $4)
RETURNING id, status, created_at;
```

#### Insertion dans l'historique

```sql
INSERT INTO request_history (request_id, previous_status, new_status, actor_id, comment)
VALUES ($1, $2, $3, $4, $5);
```

#### Mise à jour du statut (transaction)

```sql
BEGIN;

UPDATE requests
SET status = $1, updated_at = CURRENT_TIMESTAMP
WHERE id = $2;

INSERT INTO request_history (request_id, previous_status, new_status, actor_id, comment)
VALUES ($2, (SELECT status FROM requests WHERE id = $2), $1, $3, $4);

COMMIT;
```

#### Récupération des demandes d'un utilisateur

```sql
SELECT id, request_type, description, status, service, created_at, updated_at
FROM requests
WHERE user_id = $1
ORDER BY created_at DESC;
```

#### Récupération des demandes d'un service

```sql
SELECT r.id, r.request_type, r.description, r.status, r.created_at, u.username
FROM requests r
JOIN users u ON r.user_id = u.id
WHERE r.service = $1
ORDER BY r.created_at DESC;
```

#### Récupération de l'historique

```sql
SELECT rh.previous_status, rh.new_status, rh.comment, rh.created_at, u.username
FROM request_history rh
JOIN users u ON rh.actor_id = u.id
WHERE rh.request_id = $1
ORDER BY rh.created_at ASC;
```

---

## 7. Compétences Techniques à Acquérir

### 7.1. Dart et Flutter

- **Widgets avancés :** ListView, RefreshIndicator, DropdownButton
- **Gestion d'état :** Provider, ChangeNotifier
- **Navigation :** Arguments entre écrans
- **Upload de fichiers :** file_picker, lecture de fichiers
- **Indicateurs de progression**

### 7.2. Communication TCP

- **Transfert de données binaires**
- **Framing pour les blocs de fichiers**
- **Gestion des transferts longs**
- **Reprise après interruption**

### 7.3. PostgreSQL

- **Transactions :** BEGIN, COMMIT, ROLLBACK
- **Jointures :** JOIN pour récupérer les données associées
- **Contraintes CHECK :** validation au niveau SQL
- **Index :** optimisation des requêtes fréquentes

### 7.4. Gestion de fichiers

- **Lecture et écriture de fichiers**
- **Calcul de checksum SHA-256**
- **Validation de types MIME**
- **Gestion des chemins de stockage**

### 7.5. Logique métier

- **Machine à états :** transitions de statut
- **Validation des permissions**
- **Historisation des changements**

---

## 8. Collaboration avec Abdourahim et Habiba

### 8.1. Dépendances avec le module d'Abdourahim (Authentification)

**Ce que le module d'authentification fournit à Olama :**
- Le jeton de session pour chaque requête protégée
- Les informations de l'utilisateur connecté (id, rôle)
- La validation des permissions (étudiant vs agent)

**Ce qu'Olama doit demander à Abdourahim :**
- La fonction `validateToken(token)` pour vérifier les requêtes
- La fonction `getUserInfo(userId)` pour récupérer les infos
- La structure de la table `users` (champ role)

**Collaboration :**
- Semaine 1 : Définir ensemble comment le token sera passé
- Semaine 2 : Olama intègre la validation d'Abdourahim
- Semaine 3 : Tests intégrés : Olama teste ses requêtes avec les tokens

### 8.2. Dépendances avec le module d'Habiba (Suivi et notifications)

**Ce que le module de gestion des demandes fournit à Habiba :**
- Les changements de statut pour générer des notifications
- L'historique des demandes pour l'affichage
- Les informations sur les demandes pour le suivi

**Ce qu'Olama doit fournir à Habiba :**
- Une fonction `getRequestHistory(requestId)` pour l'historique
- Un événement ou callback quand le statut change
- La structure des tables requests et request_history

**Collaboration :**
- Semaine 1 : Définir ensemble comment les notifications seront déclenchées
- Semaine 2 : Olama fournit l'API de requêtes à Habiba
- Semaine 3 : Tests intégrés : Habiba teste les notifications avec les changements d'Olama

### 8.3. Activités collectives

**Tests TCP (tous les membres) :**
- Olama participe aux tests de transfert de fichiers
- Il utilise Wireshark pour vérifier les blocs
- Il teste les transferts avec Abdourahim et Habiba

**Intégration :**
- Semaine 3 : Revue croisée du code
- Olama examine le code d'Abdourahim et Habiba
- Abdourahim et Habiba examinent le code d'Olama
- Corrections collectives

---

## 9. Livrables Attendus

### 9.1. Livrables Semaine 1

- [ ] Prototype d'écran de nouvelle demande
- [ ] Prototype d'écran "Mes demandes"
- [ ] Prototype de client TCP pour SUBMIT_REQUEST
- [ ] Première version de la table `requests` en SQL
- [ ] Documentation des transitions de statut

### 9.2. Livrables Semaine 2

- [ ] Écran de nouvelle demande fonctionnel
- [ ] Écran "Mes demandes" fonctionnel
- [ ] Écran de détails de demande
- [ ] Écran de traitement des demandes (agent)
- [ ] Service RequestService complet
- [ ] Service AttachmentService complet
- [ ] Tables `requests`, `request_history`, `attachments` finalisées
- [ ] Tests unitaires des services

### 9.3. Livrables Semaine 3

- [ ] Intégration des écrans avec le serveur
- [ ] Upload de fichiers fonctionnel
- [ ] Tests d'intégration avec Abdourahim (authentification)
- [ ] Tests d'intégration avec Habiba (notifications)
- [ ] Corrections suite à revue croisée

### 9.4. Livrables Semaine 4

- [ ] Tests fonctionnels complets du module
- [ ] Tests de transfert de fichiers
- [ ] Tests de transitions de statut
- [ ] Documentation finale du module
- [ ] Participation à la démonstration globale

---

## 10. Critères de Validation

### 10.1. Critères fonctionnels

- [ ] Un étudiant peut soumettre une demande
- [ ] Un étudiant peut consulter ses demandes
- [ ] Un étudiant ne peut pas voir les demandes des autres
- [ ] Un agent peut voir les demandes de son service
- [ ] Un agent ne peut pas voir les demandes des autres services
- [ ] Un agent peut modifier le statut d'une demande
- [ ] Les transitions non autorisées sont rejetées
- [ ] Un commentaire est obligatoire pour NEEDS_INFO et REJECTED
- [ ] Un étudiant peut ajouter une pièce jointe
- [ ] Un fichier trop volumineux est rejeté
- [ ] Un fichier avec un mauvais type est rejeté
- [ ] L'historique enregistre toutes les transitions

### 10.2. Critères techniques

- [ ] Les requêtes TCP respectent le format défini
- [ ] Le transfert par blocs fonctionne correctement
- [ ] Le checksum SHA-256 est vérifié
- [ ] Les transactions PostgreSQL sont atomiques
- [ ] Les tables respectent le schéma défini
- [ ] Les index sont utilisés pour les requêtes fréquentes
- [ ] Le code gère les erreurs d'upload
- [ ] Le code gère les erreurs SQL

### 10.3. Critères d'intégration

- [ ] Abdourahim peut authentifier les requêtes d'Olama
- [ ] Habiba peut notifier les changements de statut d'Olama
- [ ] Les permissions sont correctement vérifiées
- [ ] Les tests Wireshark montrent les blocs correctement
- [ ] Le module fonctionne avec plusieurs clients

### 10.4. Critères pédagogiques

- [ ] Olama peut expliquer la logique des transitions de statut
- [ ] Olama peut expliquer le transfert par blocs
- [ ] Olama peut expliquer la structure des tables
- [ ] Olama peut modifier le code d'Abdourahim ou Habiba
- [ ] Olama a participé aux tests TCP collectifs

---

## 11. Calendrier Détaillé

### Semaine 1 — Fondations

**Lundi :**
- Apprentissage Flutter : formulaires complexes, file_picker
- Apprentissage Dart : lecture de fichiers

**Mardi :**
- Conception de la table `requests` avec Abdourahim et Habiba
- Prototype écran de nouvelle demande

**Mercredi :**
- Prototype écran "Mes demandes"
- Prototype client TCP (SUBMIT_REQUEST)

**Jeudi :**
- Implémentation du transfert par blocs
- Tests avec Wireshark (collectif)

**Vendredi :**
- Intégration prototype
- Documentation des transitions

### Semaine 2 — Développement

**Lundi :**
- Implémentation RequestService
- Création table `requests`

**Mardi :**
- Implémentation logique de transitions
- Création table `request_history`

**Mercredi :**
- Implémentation AttachmentService
- Création table `attachments`

**Jeudi :**
- Écran de détails de demande
- Écran de traitement (agent)

**Vendredi :**
- Tests unitaires des services
- Documentation des API

### Semaine 3 — Intégration

**Lundi :**
- Intégration écrans avec serveur TCP
- Tests avec Abdourahim (permissions)

**Mardi :**
- Upload de fichiers fonctionnel
- Tests avec Habiba (notifications)

**Mercredi :**
- Revue croisée du code
- Corrections

**Jeudi :**
- Tests de transferts simultanés
- Finalisation intégration

**Vendredi :**
- Documentation interne
- Préparation tests

### Semaine 4 — Validation

**Lundi :**
- Tests fonctionnels complets
- Tests de transitions

**Mardi :**
- Tests d'upload/download
- Analyse Wireshark (collectif)

**Mercredi :**
- Tests de charge
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
- File picker : https://pub.dev/packages/file_picker

### Documentation Dart
- https://dart.dev/guides
- File I/O : https://dart.dev/guides/libraries/create-library-packages#organizing-a-source-package

### Communication TCP
- Dart Socket : https://api.dart.dev/stable/dart-io/Socket-class.html
- Transfert binaire

### PostgreSQL
- Transactions : https://www.postgresql.org/docs/current/tutorial-transactions.html
- Contraintes : https://www.postgresql.org/docs/current/ddl-constraints.html

### Gestion de fichiers
- SHA-256 : https://pub.dev/packages/crypto

---

## 13. Checklist de Démarrage

Avant de commencer le développement, vérifier :

- [ ] Flutter installé et fonctionnel
- [ ] Dart installé et fonctionnel
- [ ] PostgreSQL installé et accessible
- [ ] Compréhension du README FINAL.md
- [ ] Compréhension des types de demandes
- [ ] Compréhension des statuts et transitions
- [ ] Compréhension des tables PostgreSQL à créer
- [ ] Environnement Git configuré
- [ ] IDE configuré

---

**Document rédigé pour Olama — Module Gestion des Demandes Administratives**

**Ce document constitue un guide de travail. N'hésitez pas à solliciter l'équipe pour clarifications et adaptations.**
