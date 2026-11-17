# DOCUMENTATION HABIBA — Suivi des Demandes et Notifications

**Projet :** N.O.H. CloudMesh  
**Module principal :** Suivi des demandes et notifications  
**Responsable :** Habiba

---

## 1. Rôle dans le projet

Habiba assure principalement le suivi du module de suivi des demandes et des notifications. Ce module permet aux utilisateurs de tracer l'évolution de leurs demandes et d'être informés en temps réel des changements.

Ce rôle implique :
- La conception et le développement des interfaces de suivi et d'historique
- L'implémentation du système de notifications en temps réel
- La gestion de la récupération des notifications après reconnexion
- La participation à la conception du schéma de base de données

**Important :** Habiba ne se limite pas à ce module. Elle participe également au développement Flutter global, au serveur Dart, aux tests TCP et à PostgreSQL. Les activités réseau (configuration, Wireshark, validation TCP) sont collectives et partagées entre les trois membres.

---

## 2. Module principal : Suivi des Demandes et Notifications

### 2.1. Objectif du module

Permettre aux utilisateurs de suivre l'évolution de leurs demandes via un historique détaillé et de recevoir des notifications en temps réel lorsque leur statut change.

### 2.2. Fonctionnalités principales

- Affichage de l'historique des changements de statut
- Consultation des notifications
- Réception de notifications en temps réel (connexion persistante)
- Récupération des notifications manquantes après reconnexion
- Acquittement des notifications
- Filtrage et tri de l'historique

### 2.3. Types de notifications

- Changement de statut d'une demande
- Demande d'informations complémentaires
- Approbation ou rejet d'une demande
- Nouvelle pièce jointe ajoutée

### 2.4. Historique des demandes

Chaque transition de statut est enregistrée avec :
- Le statut précédent
- Le nouveau statut
- L'auteur de la modification
- Un commentaire (obligatoire pour certaines transitions)
- La date et l'heure

---

## 3. Tâches Frontend avec Flutter

### 3.1. Écrans à développer

#### Écran d'historique (RequestHistoryScreen)

**Objectif :** Afficher l'historique complet des changements d'une demande.

**Notions à comprendre :**
- Timeline ou liste chronologique
- Affichage de métadonnées (auteur, date)
- Mise en forme conditionnelle selon le type de changement

**Technologies :**
- Flutter
- ListView personnalisé
- Formattage de dates

**Étapes de réalisation :**

1. Créer une méthode `_fetchHistory(requestId)` :
   - Envoyer une requête TCP `GET_REQUEST_HISTORY`
   - Parser la réponse JSON
   - Stocker dans une liste

2. Afficher l'historique avec une timeline :
   - Chaque élément montre : date, auteur, changement, commentaire
   - Utiliser des icônes selon le type de transition
   - Code couleur selon le statut (vert pour APPROVED, rouge pour REJECTED)

3. Implémenter le tri chronologique :
   - Du plus récent au plus ancien
   - Ou du plus ancien au plus récent (optionnel)

**Résultat attendu :**
- Une timeline claire de l'évolution de la demande
- Informations complètes sur chaque changement
- Interface intuitive et lisible

**Tests :**
- Afficher un historique vide
- Afficher un historique avec plusieurs transitions
- Vérifier que les dates sont correctement formatées
- Vérifier que les commentaires sont affichés

**Erreurs fréquentes à éviter :**
- Ne pas afficher l'auteur du changement
- Ne pas formater les dates correctement
- Confondre l'ordre chronologique

#### Écran de notifications (NotificationsScreen)

**Objectif :** Afficher la liste des notifications de l'utilisateur.

**Notions à comprendre :**
- Liste avec indicateurs de lecture (lu/non lu)
- Pull-to-refresh
- Navigation vers la demande concernée

**Étapes de réalisation :**

1. Créer une méthode `_fetchNotifications()` :
   - Envoyer une requête TCP `GET_NOTIFICATIONS`
   - Parser la réponse JSON
   - Stocker dans une liste

2. Afficher la liste avec ListView :
   - Chaque élément montre : type, message, date, statut (lu/non lu)
   - Indicateur visuel pour les notifications non lues
   - Tap sur un élément → détails de la demande

3. Implémenter l'acquittement :
   - Au tap, envoyer `ACK_NOTIFICATION`
   - Marquer comme lue localement
   - Rafraîchir la liste

4. Implémenter pull-to-refresh :
   - Recharger la liste des notifications

**Résultat attendu :**
- Liste des notifications avec indicateur de lecture
- Navigation vers les demandes concernées
- Acquittement fonctionnel

**Tests :**
- Afficher une liste vide
- Afficher des notifications lues et non lues
- Tester l'acquittement
- Tester la navigation vers la demande

#### Widget de notification en temps réel (NotificationBanner)

**Objectif :** Afficher une notification lorsqu'elle arrive en temps réel.

**Notions à comprendre :**
- Streams Dart pour les événements
- Affichage temporaire (toast/snackbar)
- Gestion des événements TCP asynchrones

**Étapes de réalisation :**

1. Créer un Stream pour les événements TCP :
   - Le client TCP émet des événements quand il reçoit un message de type EVENT
   - Les écrans s'abonnent à ce Stream

2. Créer un widget de notification :
   - Affiché en haut de l'écran
   - Disparaît automatiquement après quelques secondes
   - Bouton pour voir les détails

3. Intégrer dans les écrans principaux :
   - Tableau de bord étudiant
   - Tableau de bord agent
   - Écran de détails

**Résultat attendu :**
- Notification visible lors de la réception d'un événement
- Disparition automatique
- Possibilité de voir les détails

**Tests :**
- Simuler un événement serveur
- Vérifier que la notification s'affiche
- Vérifier qu'elle disparaît

### 3.2. Widgets réutilisables à créer

- `HistoryTimeline` : Widget d'affichage de l'historique
- `HistoryItem` : Élément individuel de l'historique
- `NotificationCard` : Carte de notification
- `NotificationBanner` : Bannière de notification temporaire

---

## 4. Tâches Backend avec Dart

### 4.1. Service de notifications (NotificationService)

**Objectif :** Gérer la création, la persistance et la diffusion des notifications.

**Notions à comprendre :**
- Gestion de connexions TCP persistantes
- Diffusion d'événements aux clients connectés
- Persistance des notifications
- Récupération après reconnexion

**Technologies :**
- Dart
- PostgreSQL (via driver)
- Gestion des connexions Socket

**Étapes de réalisation :**

#### Étape 1 : Création d'une notification

```dart
Future<Notification> createNotification({
  required int userId,
  required String eventType,
  required Map<String, dynamic> payload,
}) async {
  // 1. Générer un event_id unique
  // 2. Insérer dans PostgreSQL
  // 3. Retourner la notification créée
}
```

#### Étape 2 : Diffusion aux clients connectés

```dart
void notifyUser(int userId, Notification notification) async {
  // 1. Chercher si l'utilisateur a une connexion active
  // 2. Si oui : envoyer l'événement via TCP
  // 3. Format : {"type": "EVENT", "event": "...", "payload": {...}}
}
```

#### Étape 3 : Récupération des notifications

```dart
Future<List<Notification>> getUserNotifications(int userId) async {
  // 1. Sélectionner les notifications de l'utilisateur
  // 2. Filtrer par statut (lu/non lu) si demandé
  // 3. Trier par date décroissante
  // 4. Retourner la liste
}
```

#### Étape 4 : Récupération après reconnexion

```dart
Future<List<Notification>> getMissedNotifications(int userId, String lastEventId) async {
  // 1. Sélectionner les notifications après lastEventId
  // 2. Retourner la liste des événements manqués
}
```

#### Étape 5 : Acquittement d'une notification

```dart
Future<void> acknowledgeNotification(int notificationId) async {
  // 1. Marquer la notification comme lue dans PostgreSQL
}
```

**Résultat attendu :**
- Service capable de créer et diffuser des notifications
- Persistance pour récupération après déconnexion
- Acquittement fonctionnel

**Tests :**
- Créer une notification
- Vérifier qu'elle est persistée
- Vérifier qu'elle est envoyée au client connecté
- Tester la récupération après reconnexion
- Tester l'acquittement

**Erreurs fréquentes à éviter :**
- Ne pas persister les notifications (perte en cas de déconnexion)
- Envoyer la notification à tous les clients au lieu de l'utilisateur ciblé
- Ne pas gérer le cas où le client n'est pas connecté

### 4.2. Service d'historique (HistoryService)

**Objectif :** Gérer la consultation de l'historique des demandes.

**Étapes de réalisation :**

#### Étape 1 : Récupération de l'historique

```dart
Future<List<HistoryEntry>> getRequestHistory(int requestId) async {
  // 1. Sélectionner les entrées d'historique pour la demande
  // 2. Jointure avec users pour avoir le nom de l'auteur
  // 3. Trier par date croissante
  // 4. Retourner la liste
}
```

#### Étape 2 : Filtrage et tri

```dart
Future<List<HistoryEntry>> getRequestHistoryFiltered({
  required int requestId,
  String? statusFilter,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  // 1. Appliquer les filtres SQL
  // 2. Retourner la liste filtrée
}
```

**Résultat attendu :**
- Historique complet et trié
- Filtrage possible

**Tests :**
- Récupérer l'historique d'une demande
- Filtrer par statut
- Filtrer par date

---

## 5. Interactions TCP Nécessaires

### 5.1. Opérations du protocole

Habiba doit implémenter les actions TCP suivantes :

#### GET_REQUEST_HISTORY

**Requête client :**
```json
{
  "request_id": "req-001",
  "type": "REQUEST",
  "action": "GET_REQUEST_HISTORY",
  "token": "student-token",
  "payload": {
    "request_id": 123
  }
}
```

**Réponse serveur :**
```json
{
  "request_id": "req-001",
  "status": "SUCCESS",
  "data": {
    "history": [
      {
        "id": 1,
        "previous_status": null,
        "new_status": "SUBMITTED",
        "actor": "etudiant01",
        "comment": null,
        "created_at": "2026-01-15T10:30:00Z"
      },
      {
        "id": 2,
        "previous_status": "SUBMITTED",
        "new_status": "IN_REVIEW",
        "actor": "agent01",
        "comment": "Prise en charge",
        "created_at": "2026-01-15T14:00:00Z"
      }
    ]
  },
  "error": null
}
```

#### GET_NOTIFICATIONS

**Requête client :**
```json
{
  "request_id": "req-002",
  "type": "REQUEST",
  "action": "GET_NOTIFICATIONS",
  "token": "student-token",
  "payload": {}
}
```

**Réponse serveur :**
```json
{
  "request_id": "req-002",
  "status": "SUCCESS",
  "data": {
    "notifications": [
      {
        "id": 1,
        "event_type": "REQUEST_STATUS_CHANGED",
        "payload": {
          "request_id": 123,
          "new_status": "APPROVED"
        },
        "is_read": false,
        "created_at": "2026-01-16T09:00:00Z"
      }
    ]
  },
  "error": null
}
```

#### ACK_NOTIFICATION

**Requête client :**
```json
{
  "request_id": "req-003",
  "type": "REQUEST",
  "action": "ACK_NOTIFICATION",
  "token": "student-token",
  "payload": {
    "notification_id": 1
  }
}
```

#### Événement de notification (serveur vers client)

**Message serveur :**
```json
{
  "type": "EVENT",
  "event_id": "evt-001",
  "event": "REQUEST_STATUS_CHANGED",
  "payload": {
    "request_id": 123,
    "new_status": "APPROVED",
    "comment": "Document validé"
  }
}
```

### 5.. Implémentation de la réception d'événements

**Objectif :** Le client doit être capable de recevoir des événements asynchrones du serveur.

**Étapes de réalisation côté client :**

```dart
class TcpClient {
  late Socket _socket;
  final StreamController<Map<String, dynamic>> _eventController = StreamController.broadcast();
  
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;
  
  Future<void> connect(String host, int port) async {
    _socket = await Socket.connect(host, port);
    
    // Écouter les messages entrants
    _socket.listen(
      (data) => _handleIncomingMessage(data),
      onError: (error) => print('Erreur: $error'),
      onDone: () => print('Connexion fermée'),
    );
  }
  
  void _handleIncomingMessage(List<int> data) {
    // 1. Décoder le message (framing)
    // 2. Parser le JSON
    // 3. Si type == EVENT, émettre sur le stream
    // 4. Sinon, traiter comme réponse
  }
}
```

**Utilisation dans l'UI :**

```dart
@override
void initState() {
  super.initState();
  
  tcpClient.eventStream.listen((event) {
    if (event['event'] == 'REQUEST_STATUS_CHANGED') {
      showNotificationBanner(event['payload']);
    }
  });
}
```

**Tests :**
- Simuler un événement serveur
- Vérifier que le client le reçoit
- Vérifier que l'UI se met à jour

---

## 6. Opérations PostgreSQL Concernées

### 6.1. Tables à concevoir

#### Table `notifications`

```sql
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  event_id VARCHAR(50) UNIQUE NOT NULL,
  event_type VARCHAR(50) NOT NULL,
  payload JSONB NOT NULL,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_event ON notifications(event_id);
```

**Responsabilités :**
- Habiba conçoit cette table
- Elle définit les contraintes et index
- Elle écrit les requêtes SQL pour les opérations CRUD

**Note :** La table `request_history` est conçue en collaboration avec Olama, car elle est liée aux demandes.

### 6.2. Requêtes SQL principales

#### Création d'une notification

```sql
INSERT INTO notifications (user_id, event_id, event_type, payload)
VALUES ($1, $2, $3, $4)
RETURNING id, event_id, created_at;
```

#### Récupération des notifications d'un utilisateur

```sql
SELECT id, event_id, event_type, payload, is_read, read_at, created_at
FROM notifications
WHERE user_id = $1
ORDER BY created_at DESC;
```

#### Récupération des notifications non lues

```sql
SELECT id, event_id, event_type, payload, created_at
FROM notifications
WHERE user_id = $1 AND is_read = false
ORDER BY created_at DESC;
```

#### Acquittement d'une notification

```sql
UPDATE notifications
SET is_read = true, read_at = CURRENT_TIMESTAMP
WHERE id = $1;
```

#### Récupération des événements manqués

```sql
SELECT event_id, event_type, payload, created_at
FROM notifications
WHERE user_id = $1
  AND created_at > (SELECT created_at FROM notifications WHERE event_id = $2)
ORDER BY created_at ASC;
```

#### Nettoyage des anciennes notifications (90 jours)

```sql
DELETE FROM notifications
WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '90 days';
```

#### Récupération de l'historique (avec jointure)

```sql
SELECT rh.id, rh.previous_status, rh.new_status, rh.comment, rh.created_at, u.username
FROM request_history rh
JOIN users u ON rh.actor_id = u.id
WHERE rh.request_id = $1
ORDER BY rh.created_at ASC;
```

---

## 7. Compétences Techniques à Acquérir

### 7.1. Dart et Flutter

- **Streams :** création, écoute, broadcast
- **Widgets asynchrones :** StreamBuilder, FutureBuilder
- **Gestion d'état réactif :** réactions aux événements
- **Timelines et listes personnalisées**
- **Bannières et toasts**

### 7.2. Communication TCP

- **Connexions persistantes**
- **Réception de messages asynchrones**
- **Diffusion d'événements**
- **Gestion des reconnexions**

### 7.3. PostgreSQL

- **JSONB :** stockage de payloads structurés
- **Jointures :** récupération des données associées
- **Index sur plusieurs colonnes**
- **Nettoyage de données anciennes**

### 7.4. Logique événementielle

- **Pattern publish/subscribe**
- **Gestion d'événements en temps réel**
- **Idempotence :** gestion des doublons
- **Stratégie de livraison au moins une fois**

---

## 8. Collaboration avec Abdourahim et Olama

### 8.1. Dépendances avec le module d'Abdourahim (Authentification)

**Ce que le module d'authentification fournit à Habiba :**
- Le jeton de session pour chaque requête protégée
- Les informations de l'utilisateur connecté (id)
- La validation des permissions

**Ce qu'Habiba doit demander à Abdourahim :**
- La fonction `validateToken(token)` pour vérifier les requêtes
- La fonction `getUserId(token)` pour cibler les notifications
- La structure de la table `sessions` pour gérer les connexions actives

**Collaboration :**
- Semaine 1 : Définir ensemble comment identifier les connexions actives
- Semaine 2 : Habiba intègre la validation d'Abdourahim
- Semaine 3 : Tests intégrés : Habiba teste les notifications avec les sessions

### 8.2. Dépendances avec le module d'Olama (Gestion des demandes)

**Ce que le module de gestion des demandes fournit à Habiba :**
- Les changements de statut pour déclencher les notifications
- L'historique des demandes (table request_history)
- Les informations sur les demandes pour le contexte des notifications

**Ce qu'Habiba doit fournir à Olama :**
- Une fonction `notifyStatusChange(requestId, newStatus)` qu'Olama appelle
- La structure de la table `notifications`
- L'API de récupération de l'historique

**Collaboration :**
- Semaine 1 : Définir ensemble quand les notifications sont déclenchées
- Semaine 2 : Olama intègre les appels de notification d'Habiba
- Semaine 3 : Tests intégrés : Olama teste que les notifications sont envoyées

### 8.3. Activités collectives

**Tests TCP (tous les membres) :**
- Habiba participe aux tests de réception d'événements
- Elle utilise Wireshark pour vérifier les messages EVENT
- Elle teste les reconnexions avec Abdourahim et Olama

**Intégration :**
- Semaine 3 : Revue croisée du code
- Habiba examine le code d'Abdourahim et Olama
- Abdourahim et Olama examinent le code d'Habiba
- Corrections collectives

**Important :** Les tests Wireshark, la validation TCP et la configuration réseau sont des activités collectives. Habiba y participe au même titre que Abdourahim et Olama.

---

## 9. Livrables Attendus

### 9.1. Livrables Semaine 1

- [ ] Prototype d'écran d'historique
- [ ] Prototype d'écran de notifications
- [ ] Prototype de réception d'événements TCP
- [ ] Première version de la table `notifications` en SQL
- [ ] Documentation du système d'événements

### 9.2. Livrables Semaine 2

- [ ] Écran d'historique fonctionnel
- [ ] Écran de notifications fonctionnel
- [ ] Widget de notification en temps réel
- [ ] Service NotificationService complet
- [ ] Service HistoryService complet
- [ ] Table `notifications` finalisée
- [ ] Tests unitaires des services

### 9.3. Livrables Semaine 3

- [ ] Intégration des écrans avec le serveur
- [ ] Réception d'événements en temps réel fonctionnelle
- [ ] Tests d'intégration avec Abdourahim (authentification)
- [ ] Tests d'intégration avec Olama (déclenchement des notifications)
- [ ] Corrections suite à revue croisée

### 9.4. Livrables Semaine 4

- [ ] Tests fonctionnels complets du module
- [ ] Tests de reconnexion et récupération
- [ ] Tests de notifications simultanées
- [ ] Documentation finale du module
- [ ] Participation à la démonstration globale

---

## 10. Critères de Validation

### 10.1. Critères fonctionnels

- [ ] Un utilisateur peut consulter l'historique d'une demande
- [ ] L'historique affiche toutes les transitions
- [ ] L'historique affiche l'auteur et la date de chaque changement
- [ ] Un utilisateur peut consulter ses notifications
- [ ] Les notifications non lues sont identifiées
- [ ] Un utilisateur peut acquitter une notification
- [ ] Une notification est reçue en temps réel lors d'un changement de statut
- [ ] Les notifications manquantes sont récupérées après reconnexion
- [ ] Les notifications sont filtrées par utilisateur
- [ ] Les notifications de plus de 90 jours sont supprimées

### 10.2. Critères techniques

- [ ] Les événements TCP respectent le format défini
- [ ] Les événements sont persistés dans PostgreSQL
- [ ] Les Streams Dart fonctionnent correctement
- [ ] La réception asynchrone ne bloque pas l'UI
- [ ] La table `notifications` respecte le schéma défini
- [ ] Les index sont utilisés pour les requêtes fréquentes
- [ ] Le code gère les connexions fermées
- [ ] Le code gère les doublons d'événements (idempotence)

### 10.3. Critères d'intégration

- [ ] Abdourahim peut authentifier les requêtes d'Habiba
- [ ] Olama peut déclencher les notifications d'Habiba
- [ ] Les notifications sont envoyées uniquement à l'utilisateur concerné
- [ ] Les tests Wireshark montrent les messages EVENT correctement
- [ ] Le module fonctionne avec plusieurs clients connectés

### 10.4. Critères pédagogiques

- [ ] Habiba peut expliquer le fonctionnement des Streams Dart
- [ ] Habiba peut expliquer le système d'événements TCP
- [ ] Habiba peut expliquer la structure de la table notifications
- [ ] Habiba peut modifier le code d'Abdourahim ou Olama
- [ ] Habiba a participé aux tests TCP collectifs

---

## 11. Calendrier Détaillé

### Semaine 1 — Fondations

**Lundi :**
- Apprentissage Flutter : Streams, StreamBuilder
- Apprentissage Dart : communication asynchrone

**Mardi :**
- Conception de la table `notifications` avec Abdourahim et Olama
- Prototype écran d'historique

**Mercredi :**
- Prototype écran de notifications
- Prototype réception d'événements TCP

**Jeudi :**
- Implémentation des Streams
- Tests avec Wireshark (collectif)

**Vendredi :**
- Intégration prototype
- Documentation des événements

### Semaine 2 — Développement

**Lundi :**
- Implémentation NotificationService
- Création table `notifications`

**Mardi :**
- Implémentation diffusion d'événements
- Implémentation récupération

**Mercredi :**
- Implémentation HistoryService
- Écran de notifications complet

**Jeudi :**
- Widget de notification en temps réel
- Tests unitaires des services

**Vendredi :**
- Documentation des API
- Tests de persistance

### Semaine 3 — Intégration

**Lundi :**
- Intégration écrans avec serveur TCP
- Tests avec Abdourahim (sessions)

**Mardi :**
- Intégration avec Olama (déclenchement)
- Tests de notifications temps réel

**Mercredi :**
- Revue croisée du code
- Corrections

**Jeudi :**
- Tests de reconnexion
- Finalisation intégration

**Vendredi :**
- Documentation interne
- Préparation tests

### Semaine 4 — Validation

**Lundi :**
- Tests fonctionnels complets
- Tests d'historique

**Mardi :**
- Tests de notifications
- Analyse Wireshark (collectif)

**Mercredi :**
- Tests de reconnexion
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
- Streams : https://dart.dev/guides/libraries/library-tour#streams

### Documentation Dart
- https://dart.dev/guides
- Async programming : https://dart.dev/guides/language/language-tour#asynchrony
- Streams : https://dart.dev/tutorials/language/streams

### Communication TCP
- Dart Socket : https://api.dart.dev/stable/dart-io/Socket-class.html
- Événements asynchrones

### PostgreSQL
- JSONB : https://www.postgresql.org/docs/current/datatype-json.html
- Index : https://www.postgresql.org/docs/current/indexes.html

---

## 13. Checklist de Démarrage

Avant de commencer le développement, vérifier :

- [ ] Flutter installé et fonctionnel
- [ ] Dart installé et fonctionnel
- [ ] PostgreSQL installé et accessible
- [ ] Compréhension du README FINAL.md
- [ ] Compréhension des types de notifications
- [ ] Compréhension du système d'événements TCP
- [ ] Compréhension de la table notifications à créer
- [ ] Environnement Git configuré
- [ ] IDE configuré

---

**Document rédigé pour Habiba — Module Suivi des Demandes et Notifications**

**Ce document constitue un guide de travail. N'hésitez pas à solliciter l'équipe pour clarifications et adaptations.**
