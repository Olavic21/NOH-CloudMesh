# N.O.H. CloudMesh
## Spécification technique générale du système
**Version :** 1.0 – Document de référence pour le développement  
**Environnement :** Réseau local universitaire (LAN)  
**Serveur :** Ubuntu Server 24.04 LTS  
**Technologies :** Flutter, Dart, TCP, JSON, PostgreSQL  
**Architecture :** Client-serveur centralisée

---

# 1. PRÉSENTATION GÉNÉRALE

## 1.1. Contexte

N.O.H. CloudMesh est une application de gestion et de suivi des demandes administratives universitaires. Elle vise à résoudre le manque de visibilité des étudiants sur l'état de leurs demandes et les difficultés liées à leur suivi.

La plateforme permet aux étudiants de soumettre des demandes, de consulter leur progression et de recevoir des notifications. Les agents administratifs disposent d'un espace de traitement adapté à leur service, tandis que les administrateurs assurent la gestion globale du système.

## 1.2. Objectif général

Concevoir et développer une application client-serveur de gestion et de suivi des demandes administratives universitaires, reposant sur une communication TCP développée avec Dart et accessible sur le réseau local de l'établissement.

## 1.3. Problématique

Comment concevoir un système client-serveur permettant de centraliser le traitement des demandes administratives universitaires et d'assurer leur suivi transparent par les étudiants, grâce à une communication TCP implémentée en Dart sur un réseau local ?

## 1.4. Périmètre fonctionnel

Le MVP comprend quatre modules :

1. Authentification et gestion des utilisateurs.
2. Gestion des demandes administratives.
3. Suivi, historique et notifications.
4. Administration des comptes et des services.

Les types de demandes pris en charge sont :

- Attestation de scolarité.
- Certificat de scolarité.
- Relevé de notes.
- Réclamation administrative.

## 1.5. Éléments exclus du MVP

- Synchronisation avec un cloud.
- Accès distant via Internet.
- Intelligence artificielle.
- Messagerie instantanée générale.
- Gestion générale des annonces universitaires.
- Architecture distribuée ou véritable réseau maillé.

Le nom CloudMesh est conservé comme identité du projet, mais l'architecture technique est centralisée.

---

# 2. ARCHITECTURE TECHNIQUE GÉNÉRALE

## 2.1. Architecture retenue

L'application adopte une architecture client-serveur centralisée.

Elle comporte trois couches :

### Couche cliente

Technologie : Flutter / Dart.

Elle comprend trois interfaces :

- Étudiant.
- Agent administratif.
- Administrateur.

Les clients communiquent avec le serveur à l'aide de `Socket` de Dart.

### Couche serveur

Technologie : Dart sur Ubuntu Server 24.04 LTS.

Elle assure :

- L'écoute des connexions TCP.
- L'authentification.
- Le contrôle des permissions.
- Le traitement des demandes.
- La gestion des notifications.
- Le transfert des fichiers.
- Les interactions avec PostgreSQL.

Le serveur utilise `ServerSocket` de Dart.

### Couche de données

Technologie : PostgreSQL.

Elle stocke :

- Les utilisateurs.
- Les rôles.
- Les services.
- Les demandes.
- L'historique.
- Les sessions.
- Les notifications.
- Les métadonnées des pièces jointes.

Les clients ne communiquent jamais directement avec PostgreSQL.

## 2.2. Schéma logique

```text
        RÉSEAU LOCAL UNIVERSITAIRE
                  |
       +----------+----------+
       |          |          |
   Étudiant     Agent      Admin
   Flutter     Flutter     Flutter
       |          |          |
       +----------+----------+
                  |
             TCP / JSON
                  |
       +----------------------+
       |    SERVEUR DART      |
       |----------------------|
       | Authentification     |
       | Contrôle d'accès     |
       | Gestion des demandes|
       | Notifications        |
       | Gestion des fichiers |
       | Logique métier       |
       +----------------------+
                  |
             SQL / Driver
                  |
       +----------------------+
       |     PostgreSQL       |
       +----------------------+
```

## 2.3. Fonctionnement sans Internet

Le système doit continuer à fonctionner lorsque l'accès Internet est indisponible, à condition que le serveur et le réseau local restent opérationnels.

Il ne garantit pas la continuité de service en cas de panne du serveur central.

---

# 3. SPÉCIFICATION DU PROTOCOLE DE COMMUNICATION TCP

## 3.1. Principe

TCP constitue le protocole de transport des échanges entre les clients Flutter et le serveur Dart.

Le projet ne redéfinit pas TCP. Il définit un protocole applicatif reposant sur TCP.

Ce protocole précise :

- Le format des messages.
- Les opérations disponibles.
- Les réponses du serveur.
- Les événements de notification.
- Les règles d'authentification.
- La gestion des erreurs.
- Le cycle de vie des connexions.

## 3.2. Établissement d'une connexion

1. Le serveur démarre et écoute sur un port défini.
2. Le client établit une connexion TCP.
3. Le serveur accepte la connexion.
4. Le client peut transmettre une requête d'authentification.
5. Le serveur vérifie les identifiants.
6. Une session est créée après authentification réussie.

Les adresses IP et le port définitifs seront déterminés lors de la configuration du laboratoire.

## 3.3. Format des messages

Les échanges utilisent JSON encodé en UTF-8.

Le protocole utilise le mécanisme Length-Prefix Framing.

Chaque message comprend :

| Élément | Taille | Description |
|---|---:|---|
| Préfixe | 4 octets | Taille du message |
| Corps | Variable | Message JSON en UTF-8 |

Le préfixe est un entier non signé de 32 bits, représenté en Big Endian.

La taille maximale proposée pour un message JSON est de 1 Mio.

Le système doit gérer :

- Les messages fragmentés.
- Les messages regroupés dans un même flux TCP.
- Les messages incomplets.
- Les messages trop volumineux.
- Les erreurs de décodage.

## 3.4. Structure standard d'une requête

```json
{
  "request_id": "req-001",
  "type": "REQUEST",
  "action": "GET_MY_REQUESTS",
  "token": "session-token",
  "payload": {}
}
```

| Champ | Type | Rôle |
|---|---|---|
| `request_id` | String | Identifiant unique |
| `type` | String | Type de message |
| `action` | String | Opération demandée |
| `token` | String | Jeton de session si nécessaire |
| `payload` | Object | Paramètres de l'opération |

Le jeton est absent pour les opérations publiques, notamment `LOGIN`.

## 3.5. Structure standard d'une réponse

```json
{
  "request_id": "req-001",
  "status": "SUCCESS",
  "data": {},
  "error": null
}
```

| Champ | Description |
|---|---|
| `request_id` | Reprend l'identifiant de la requête |
| `status` | `SUCCESS` ou `ERROR` |
| `data` | Résultat de l'opération |
| `error` | Informations sur l'erreur éventuelle |

## 3.6. Liste des opérations applicatives

| Action | Fonction | Acteur |
|---|---|---|
| `LOGIN` | Authentification | Tous |
| `LOGOUT` | Déconnexion | Tous |
| `SUBMIT_REQUEST` | Soumettre une demande | Étudiant |
| `GET_MY_REQUESTS` | Consulter ses demandes | Étudiant |
| `GET_REQUEST_DETAILS` | Consulter une demande | Selon permissions |
| `UPDATE_REQUEST_STATUS` | Modifier le statut | Agent autorisé |
| `GET_REQUEST_HISTORY` | Consulter l'historique | Selon permissions |
| `UPLOAD_ATTACHMENT` | Transférer un fichier | Étudiant autorisé |
| `DOWNLOAD_ATTACHMENT` | Télécharger un fichier | Selon permissions |
| `GET_NOTIFICATIONS` | Récupérer les notifications | Tous |
| `ACK_NOTIFICATION` | Acquitter une notification | Tous |
| `CREATE_USER` | Créer un compte | Administrateur |
| `ASSIGN_AGENT` | Affecter un agent à un service | Administrateur |

Cette liste constitue le catalogue initial. Les paramètres précis de chaque action devront être documentés dans la spécification détaillée du protocole.

## 3.7. Codes d'erreur

| Code | Signification |
|---|---|
| `INVALID_MESSAGE` | Message mal formé |
| `INVALID_CREDENTIALS` | Identifiants incorrects |
| `UNAUTHORIZED` | Session absente ou invalide |
| `FORBIDDEN` | Permission insuffisante |
| `NOT_FOUND` | Ressource inexistante |
| `INVALID_STATUS_TRANSITION` | Transition interdite |
| `FILE_TOO_LARGE` | Fichier trop volumineux |
| `INTERNAL_ERROR` | Erreur interne |

Les réponses d'erreur ne doivent pas exposer les informations sensibles du serveur.

## 3.8. Gestion des connexions simultanées

Le serveur doit :

- Accepter plusieurs clients simultanément.
- Associer chaque connexion à son contexte de session.
- Isoler les erreurs d'un client des autres connexions.
- Gérer les déconnexions.
- Fermer les connexions inactives selon une durée définie.
- Éviter qu'une requête bloque le traitement des autres clients.

---

# 4. AUTHENTIFICATION ET GESTION DES SESSIONS

## 4.1. Principe retenu

L'authentification repose sur un identifiant et un mot de passe.

Après vérification, le serveur génère un jeton de session opaque.

Chaque requête protégée doit contenir un jeton valide.

## 4.2. Processus d'authentification

1. Le client transmet ses identifiants.
2. Le serveur recherche le compte.
3. Le mot de passe est vérifié à partir de son empreinte sécurisée.
4. Le serveur génère un jeton aléatoire.
5. Le jeton est associé à l'utilisateur et à une session.
6. Le serveur retourne le jeton au client.

Exemple :

```json
{
  "request_id": "req-002",
  "type": "REQUEST",
  "action": "LOGIN",
  "payload": {
    "username": "etudiant01",
    "password": "mot_de_passe"
  }
}
```

Réponse :

```json
{
  "request_id": "req-002",
  "status": "SUCCESS",
  "data": {
    "token": "generated-session-token",
    "user": {
      "id": 15,
      "role": "STUDENT"
    }
  },
  "error": null
}
```

## 4.3. Règles de session

- Le jeton est généré côté serveur.
- Il doit être suffisamment aléatoire et imprévisible.
- Son empreinte est conservée dans PostgreSQL.
- Chaque requête protégée fait l'objet d'une vérification.
- Chaque session possède une date d'expiration.
- La déconnexion invalide la session.
- Le serveur peut révoquer une session.

Les mots de passe sont hachés avec un algorithme adapté, tel qu'Argon2id ou bcrypt.

Le jeton ne remplace pas le chiffrement de la communication : TLS reste nécessaire pour protéger les échanges.

---

# 5. GESTION DES RÔLES ET DES PERMISSIONS

## 5.1. Rôles

| Rôle | Responsabilités |
|---|---|
| `STUDENT` | Soumettre et suivre ses demandes |
| `AGENT` | Traiter les demandes de son service |
| `ADMIN` | Administrer les comptes et les services |

## 5.2. Permissions des étudiants

L'étudiant peut :

- Soumettre une demande.
- Consulter ses demandes.
- Consulter l'historique.
- Ajouter les informations complémentaires requises.
- Télécharger ses pièces jointes autorisées.
- Consulter ses notifications.

Il ne peut pas consulter les demandes des autres étudiants ni modifier lui-même le statut de ses demandes.

## 5.3. Permissions des agents

Les agents sont affectés à un service administratif.

Exemple :

| Service | Demandes |
|---|---|
| Scolarité | Attestations et certificats |
| Examens | Relevés de notes |
| Réclamations | Réclamations administratives |

Un agent peut consulter et traiter uniquement les demandes relevant de son service.

Le contrôle est effectué par le serveur à chaque opération.

## 5.4. Permissions des administrateurs

L'administrateur peut :

- Créer et désactiver les comptes.
- Attribuer les rôles.
- Gérer les services.
- Affecter les agents.
- Consulter toutes les demandes.
- Consulter les activités du système.

---

# 6. GESTION DES PIÈCES JOINTES

## 6.1. Principe retenu

Les fichiers sont stockés sur le système de fichiers du serveur.

PostgreSQL conserve leurs métadonnées et leur emplacement.

## 6.2. Paramètres proposés

- Formats acceptés : PDF, JPG, PNG.
- Taille maximale : 5 Mo par fichier.
- Taille d'un bloc de transfert : 48 Kio de données binaires.
- Empreinte d'intégrité : SHA-256.

## 6.3. Processus de transfert

1. Le client envoie une demande de transfert.
2. Le serveur vérifie l'authentification et les permissions.
3. Le serveur valide les métadonnées du fichier.
4. Le client transmet le fichier par blocs.
5. Le serveur reconstitue le fichier.
6. Le serveur vérifie son intégrité.
7. Le serveur stocke le fichier.
8. Les métadonnées sont enregistrées dans PostgreSQL.
9. Le serveur confirme la fin du transfert.

Le protocole de transfert devra définir les identifiants de transfert, numéros de séquence, confirmations de blocs et gestion des transferts interrompus.

Pour le prototype, les blocs peuvent être encapsulés dans des messages JSON utilisant Base64. Cette approche devra être testée en raison de son surcoût en taille et en mémoire.

## 6.4. Organisation du stockage

```text
server/
├── uploads/
│   ├── 2026/
│   │   ├── request_001/
│   │   └── request_002/
├── src/
└── main.dart
```

Les noms physiques des fichiers sont générés par le serveur.

Le téléchargement passe obligatoirement par le serveur, qui vérifie les permissions avant de transmettre le fichier.

## 6.5. Métadonnées

Table `attachments` :

| Champ | Description |
|---|---|
| `id` | Identifiant |
| `request_id` | Demande associée |
| `original_name` | Nom original |
| `stored_name` | Nom physique |
| `mime_type` | Type du fichier |
| `file_size` | Taille |
| `storage_path` | Emplacement |
| `checksum` | Empreinte SHA-256 |
| `uploaded_at` | Date de transfert |

---

# 7. NOTIFICATIONS ET RECONNEXION

## 7.1. Principe retenu

Les notifications utilisent une connexion TCP persistante.

Le serveur peut transmettre des événements sans attendre une nouvelle requête du client.

## 7.2. Fonctionnement

Lorsqu'un agent modifie le statut d'une demande :

1. Le serveur vérifie les permissions.
2. Il enregistre le changement dans PostgreSQL.
3. Il crée une notification persistante.
4. Il transmet l'événement au client connecté.
5. Le client actualise son interface.

Exemple :

```json
{
  "type": "EVENT",
  "event_id": "evt-001",
  "event": "REQUEST_STATUS_CHANGED",
  "payload": {
    "request_id": 12,
    "new_status": "APPROVED"
  }
}
```

## 7.3. Récupération après reconnexion

Les notifications sont conservées dans PostgreSQL.

Lorsqu'un utilisateur se reconnecte :

1. Le client ouvre une connexion TCP.
2. Il s'authentifie.
3. Il indique le dernier événement confirmé.
4. Le serveur récupère les notifications non acquittées.
5. Le serveur retransmet les événements manquants.
6. Le client traite les événements et envoie leur acquittement.

Un identifiant unique `event_id` permet de reconnaître les événements déjà traités.

Le système adopte une stratégie de livraison au moins une fois : un événement peut être transmis plusieurs fois, mais son traitement doit être idempotent.

---

# 8. CYCLE DE VIE DES DEMANDES

## 8.1. Statuts

| Statut | Signification |
|---|---|
| `SUBMITTED` | Demande soumise |
| `IN_REVIEW` | En cours de traitement |
| `NEEDS_INFO` | Informations complémentaires requises |
| `APPROVED` | Demande approuvée |
| `REJECTED` | Demande rejetée |

## 8.2. Transitions autorisées

| Statut initial | Statut final | Acteur |
|---|---|---|
| SUBMITTED | IN_REVIEW | Agent autorisé |
| IN_REVIEW | NEEDS_INFO | Agent autorisé |
| NEEDS_INFO | IN_REVIEW | Agent autorisé |
| IN_REVIEW | APPROVED | Agent autorisé |
| IN_REVIEW | REJECTED | Agent autorisé |

Toute transition non autorisée est refusée.

Un commentaire est obligatoire pour les demandes d'informations complémentaires et les rejets.

## 8.3. Historique

Chaque transition est enregistrée dans `request_history`.

Champs :

- `id`
- `request_id`
- `previous_status`
- `new_status`
- `actor_id`
- `comment`
- `created_at`

L'historique est chronologique et ne peut pas être modifié par les utilisateurs ordinaires.

Les modifications de statut et l'enregistrement de l'historique doivent être réalisés dans une même transaction PostgreSQL.

---

# 9. MODÈLE DE DONNÉES POSTGRESQL

## 9.1. Tables principales

| Table | Responsabilité |
|---|---|
| `users` | Comptes utilisateurs |
| `roles` | Rôles |
| `services` | Services administratifs |
| `agent_services` | Affectations des agents |
| `requests` | Demandes administratives |
| `request_history` | Historique |
| `attachments` | Métadonnées des fichiers |
| `sessions` | Sessions d'authentification |
| `notifications` | Notifications persistantes |

## 9.2. Relations principales

- Un utilisateur peut soumettre plusieurs demandes.
- Une demande appartient à un étudiant.
- Une demande appartient à un type administratif.
- Une demande possède plusieurs entrées d'historique.
- Une demande peut contenir plusieurs pièces jointes.
- Un agent peut être affecté à un ou plusieurs services si l'équipe retient cette possibilité.
- Un utilisateur peut posséder plusieurs sessions.
- Un utilisateur peut recevoir plusieurs notifications.

## 9.3. Contraintes

- Chaque compte possède un identifiant unique.
- Chaque demande possède un identifiant unique.
- Les clés étrangères garantissent la cohérence des relations.
- Les transitions de statut sont validées par la logique métier.
- Les changements de statut et leur historique sont transactionnels.
- Les sessions révoquées ou expirées ne peuvent plus être utilisées.

Le schéma SQL détaillé sera produit à partir de ce modèle.

---

# 10. SÉCURITÉ ET FIABILITÉ

Le système doit intégrer les mesures suivantes :

1. Authentification pour les opérations privées.
2. Contrôle des permissions côté serveur.
3. Hachage sécurisé des mots de passe.
4. Expiration et révocation des sessions.
5. Validation des messages JSON.
6. Validation des fichiers.
7. Protection contre l'accès non autorisé aux demandes.
8. Journalisation des opérations sensibles.
9. Gestion des erreurs et déconnexions.
10. Protection des échanges par TLS lorsque l'environnement le permet.

**Limite :** TCP seul n'assure pas le chiffrement. Les identifiants, jetons et fichiers transmis ne sont donc pas confidentiels sans mécanisme supplémentaire comme TLS.

Le système ne doit pas être présenté comme tolérant aux pannes du serveur central.

---

# 11. SPÉCIFICATION DES INTERFACES UTILISATEUR

## 11.1. Interface étudiant

Écrans principaux :

- Connexion.
- Tableau de bord.
- Nouvelle demande.
- Mes demandes.
- Détails d'une demande.
- Historique.
- Notifications.
- Profil.

Chaque écran doit correspondre à des opérations applicatives identifiées.

## 11.2. Interface agent

Écrans principaux :

- Connexion.
- Tableau de bord du service.
- Liste des demandes du service.
- Détails d'une demande.
- Traitement d'une demande.
- Historique.
- Notifications.

## 11.3. Interface administrateur

Écrans principaux :

- Connexion.
- Tableau de bord général.
- Gestion des utilisateurs.
- Gestion des rôles.
- Gestion des services.
- Affectation des agents.
- Consultation globale des demandes.
- Activité du système.

---

# 12. DIAGRAMMES UML À PRODUIRE

La documentation de conception devra comprendre les diagrammes suivants.

## 12.1. Diagramme de cas d'utilisation

Acteurs :

- Étudiant.
- Agent administratif.
- Administrateur.

Cas d'utilisation :

- S'authentifier.
- Soumettre une demande.
- Suivre une demande.
- Consulter l'historique.
- Ajouter une pièce jointe.
- Traiter une demande.
- Recevoir une notification.
- Gérer les utilisateurs.
- Affecter un agent à un service.

## 12.2. Diagramme de classes

Classes principales envisagées :

- `User`
- `Student`
- `Agent`
- `Administrator`
- `Service`
- `Request`
- `RequestHistory`
- `Attachment`
- `Session`
- `Notification`

La nécessité d'utiliser des sous-classes ou une simple classe `User` avec des rôles sera décidée pendant la conception détaillée.

## 12.3. Diagrammes de séquence

Quatre séquences prioritaires :

1. Authentification d'un utilisateur.
2. Soumission d'une demande avec pièce jointe.
3. Traitement d'une demande par un agent.
4. Notification et récupération après reconnexion.

## 12.4. Diagramme d'activité

Il représentera le cycle complet d'une demande, de sa soumission à sa décision finale.

---

# 13. ORGANISATION DU CODE

Une organisation indicative est proposée.

## 13.1. Serveur Dart

```text
server/
├── lib/
│   ├── network/
│   │   ├── tcp_server.dart
│   │   ├── connection_handler.dart
│   │   └── message_framing.dart
│   ├── protocol/
│   │   ├── request.dart
│   │   ├── response.dart
│   │   ├── event.dart
│   │   └── protocol_constants.dart
│   ├── auth/
│   │   ├── auth_service.dart
│   │   └── session_service.dart
│   ├── services/
│   │   ├── request_service.dart
│   │   ├── notification_service.dart
│   │   ├── attachment_service.dart
│   │   └── user_service.dart
│   ├── database/
│   │   └── database_connection.dart
│   └── main.dart
├── uploads/
├── test/
└── pubspec.yaml
```

## 13.2. Client Flutter

```text
client/
├── lib/
│   ├── core/
│   │   ├── network/
│   │   ├── protocol/
│   │   └── session/
│   ├── models/
│   ├── services/
│   ├── features/
│   │   ├── authentication/
│   │   ├── student/
│   │   ├── agent/
│   │   └── administration/
│   ├── widgets/
│   └── main.dart
├── test/
└── pubspec.yaml
```

Cette structure est une proposition d'organisation, non une obligation définitive.

---

# 14. RÉPARTITION DES RESPONSABILITÉS

| Membre | Responsabilités | Livrables |
|---|---|---|
| Abdourahim | Frontend Flutter et intégration client TCP | Interfaces, navigation, client réseau |
| Olama | Backend Dart et base PostgreSQL | Serveur TCP, logique métier, base de données |
| Habiba | Protocole TCP et validation des communications | Spécification protocolaire, client Dart de test, scénarios de validation, analyses Wireshark |

Les trois membres participent à la définition du protocole et à la validation du prototype.

Habiba doit développer un client Dart indépendant capable de communiquer avec le serveur sans dépendre de l'interface Flutter.

---

# 15. PLAN DE DÉVELOPPEMENT SUR QUATRE SEMAINES

## Semaine 1 — Conception et prototype TCP

- Validation du périmètre.
- Définition du protocole.
- Définition du framing.
- Mise en place du serveur Dart.
- Développement d'un client Dart de test.
- Premiers échanges JSON.

**Livrable :** prototype TCP opérationnel.

## Semaine 2 — Développement des composants

- Mise en place de PostgreSQL.
- Authentification et sessions.
- Développement des interfaces Flutter.
- Gestion des utilisateurs.
- Développement des tests protocolaires.

**Livrable :** composants principaux fonctionnels indépendamment.

## Semaine 3 — Intégration

- Intégration Flutter et serveur.
- Soumission des demandes.
- Gestion des statuts.
- Historique.
- Notifications.
- Gestion des pièces jointes.

**Livrable :** parcours administratif complet.

## Semaine 4 — Validation et démonstration

- Tests fonctionnels.
- Tests de communication TCP.
- Tests de connexions simultanées.
- Tests de reconnexion.
- Analyse Wireshark.
- Tests de fonctionnement sans Internet.
- Documentation et préparation de la démonstration.

**Livrable :** MVP intégré et démontrable.

---

# 16. PLAN DE VALIDATION ET CRITÈRES DE RÉUSSITE

| Test | Résultat attendu |
|---|---|
| Connexion valide | Authentification réussie |
| Mauvais identifiants | Accès refusé |
| Consultation étudiant | Uniquement ses propres demandes |
| Consultation agent | Uniquement les demandes de son service |
| Modification du statut | Transition autorisée enregistrée |
| Historique | Chronologie complète |
| Notification | Événement reçu en temps réel |
| Reconnexion | Notifications manquantes récupérées |
| Transfert de fichier | Fichier stocké et métadonnées persistées |
| Téléchargement interdit | Accès refusé |
| Message fragmenté | Reconstitution correcte |
| Plusieurs messages regroupés | Traitement individuel correct |
| Plusieurs clients simultanés | Connexions prises en charge |
| Coupure Internet | Application toujours opérationnelle sur le LAN |

---

# 17. SCÉNARIO DE DÉMONSTRATION

La démonstration finale suivra ce parcours :

1. Un étudiant se connecte.
2. Il soumet une demande d'attestation de scolarité.
3. Il ajoute une pièce justificative.
4. Le serveur reçoit la requête TCP et enregistre les données dans PostgreSQL.
5. Un agent du service de scolarité se connecte.
6. Il consulte la demande et la prend en charge.
7. Il approuve ou demande des informations complémentaires.
8. Le serveur enregistre la transition et crée une notification.
9. L'étudiant reçoit la notification.
10. L'étudiant consulte l'état actualisé et l'historique.
11. Une déconnexion est simulée, puis une reconnexion permet de récupérer les événements manqués.
12. Une coupure Internet est simulée alors que le LAN reste fonctionnel.

Cette démonstration doit montrer à la fois la valeur fonctionnelle de l'application et la maîtrise technique de la communication TCP.

---

# 18. DÉCISIONS TECHNIQUES ET POINTS À VALIDER

| Élément | Orientation retenue |
|---|---|
| Architecture | Client-serveur centralisée |
| Réseau | LAN uniquement |
| Client | Flutter / Dart |
| Serveur | Dart / Ubuntu Server 24.04 |
| Transport | TCP |
| Format des messages | JSON / UTF-8 |
| Framing | Préfixe de 4 octets Big Endian |
| Base de données | PostgreSQL |
| Pièces jointes | Stockage serveur, métadonnées PostgreSQL |
| Notifications | TCP persistant et récupération après reconnexion |
| Authentification | Jeton de session vérifié à chaque requête |
| Agents | Accès limité à leur service |
| Taille maximale d'un fichier | 5 Mo |
| Taille maximale d'un message JSON | 1 Mio |
| Taille des blocs de transfert | 48 Kio |
| Chiffrement | NON implémenté dans le MVP (limitation documentée) |

## Décisions techniques définitives (arbitrages)

1. **Durée d'expiration des sessions :** 30 minutes d'inactivité pour les étudiants, 2 heures pour les agents et administrateurs
2. **Durée maximale d'inactivité d'une connexion TCP :** 5 minutes sans envoi de données, keep-alive toutes les 60 secondes
3. **Possibilité pour un agent d'appartenir à plusieurs services :** NON, un agent est affecté à un seul service
4. **Attribution des demandes aux agents :** Attribution manuelle par l'agent (premier arrivé, premier servi)
5. **Annulation d'une demande par un étudiant :** NON, une fois soumise, la demande ne peut être annulée que par un agent
6. **Règles de reprise des transferts de fichiers interrompus :** Reprise automatique à partir du dernier bloc confirmé, timeout 5 minutes
7. **Confirmation des notifications et politique de rétention :** Acquittement manuel par l'utilisateur, rétention 90 jours
8. **Port TCP :** Port 8080 (pas de TLS pour le MVP)
9. **Mécanisme TLS :** NON implémenté dans le MVP (documenté comme limitation)
10. **Politique de sauvegarde :** Backup PostgreSQL quotidien à 2h du matin, rétention 30 jours ; backup fichiers hebdomadaire, rétention 7 jours

## Décisions techniques complémentaires

### 1. Gestion des sessions et sécurité

- **Expiration des sessions :** 30 minutes d'inactivité pour les étudiants, 2 heures pour les agents/admin
- **Régénération de jeton :** Renouvellement automatique du token à 50% de sa durée de vie
- **Concurrent sessions :** 1 session active par utilisateur (nouvelle connexion invalide l'ancienne)
- **Verrouillage compte :** Après 5 tentatives échouées, verrouillage temporaire de 15 minutes

### 2. Performance et scalabilité

- **Connexions simultanées :** Cible de 50 connexions simultanées pour le MVP
- **Pool de connexions PostgreSQL :** Pool de 15 connexions
- **Timeout des requêtes :** 30 secondes maximum par requête
- **Gestion de la charge :** File d'attente pour les opérations longues (transferts fichiers)

### 3. Gestion des fichiers

- **Nettoyage automatique :** Suppression des fichiers orphelins après 7 jours
- **Quota utilisateur :** 100 Mo par étudiant pour l'ensemble de ses pièces jointes
- **Compression :** NON implémenté dans le MVP
- **Versionning :** Conserver uniquement la dernière version d'une pièce jointe par demande

### 4. Notifications

- **Politique de rétention :** 90 jours pour les notifications, puis suppression
- **Priorité des notifications :** NON implémenté dans le MVP (toutes normales)
- **Mode silencieux :** NON implémenté dans le MVP
- **Agrégation :** NON implémenté dans le MVP

### 5. Base de données

- **Indexation :** Index sur (user_id, status) pour les requêtes fréquentes
- **Partitionnement :** NON implémenté dans le MVP
- **Backup :** Backup quotidien à 2h du matin, rétention 30 jours
- **Migration :** Script de migration automatique des données lors des mises à jour de schéma

### 6. Réseau et protocole

- **Port TCP :** Port 8080
- **Keep-alive :** Ping toutes les 60 secondes pour détecter les connexions mortes
- **Reconnexion automatique :** Client tente de se reconnecter avec délai exponentiel (1s, 2s, 4s, 8s, max 30s)
- **Compression JSON :** NON implémenté dans le MVP

### 7. Logging et monitoring

- **Niveaux de log :** DEBUG, INFO, WARNING, ERROR, CRITICAL
- **Rotation des logs :** Rotation quotidienne, rétention 7 jours
- **Métriques :** Enregistrer le nombre de requêtes par type, temps de réponse, erreurs
- **Alertes :** NON implémenté dans le MVP (logs manuels)

### 8. Interface utilisateur

- **Thème :** Mode clair uniquement
- **Responsive :** Mobiles uniquement (pas de tablettes dans le MVP)
- **Accessibilité :** Conformité WCAG 2.1 niveau AA (contraste, taille de police)
- **Langue :** Français uniquement

## Points à valider par priorité

### Priorité haute (bloquant pour le MVP)

1. **Framing TCP :** Validation du mécanisme Length-Prefix avec messages fragmentés/regroupés
2. **Authentification :** Validation du flux complet login → token → requêtes protégées
3. **Permissions :** Validation que les agents ne voient que leur service
4. **Transitions de statut :** Validation que les transitions non autorisées sont rejetées
5. **Transactions PostgreSQL :** Validation de l'atomicité des changements de statut + historique
6. **Notifications temps réel :** Validation de la réception immédiate sur connexion persistante
7. **Reconnexion :** Validation de la récupération des événements manqués

### Priorité moyenne (important pour la qualité)

1. **Transfert fichiers :** Validation du transfert par blocs et vérification SHA-256
2. **Connexions simultanées :** Validation avec 5-10 clients connectés en même temps
3. **Gestion des erreurs :** Validation que les erreurs d'un client n'affectent pas les autres
4. **Timeout :** Validation que les requêtes trop longues sont interrompues
5. **Validation fichiers :** Validation des types MIME et tailles maximales
6. **Historique complet :** Validation que toutes les transitions sont tracées

### Priorité basse (améliorations)

1. **Performance :** Mesure du temps de réponse typique (< 500ms pour 90% des requêtes)
2. **Charge soutenue :** Test avec 20-30 utilisateurs simultanés
3. **Fonctionnement sans Internet :** Validation que le LAN seul suffit
4. **Nettoyage fichiers :** Validation de la suppression des fichiers orphelins
5. **Backup/restore :** Validation de la récupération après incident

## Critères de validation technique

### Validation du protocole TCP

- [ ] Wireshark capture montre des messages correctement framés
- [ ] Messages fragmentés sont reconstitués correctement
- [ ] Plusieurs messages dans un même paquet sont traités individuellement
- [ ] Taille du préfixe est correctement interprétée (Big Endian)
- [ ] Messages invalides sont rejetés avec erreur appropriée

### Validation de la sécurité

- [ ] Mots de passe hachés avec bcrypt
- [ ] Tokens de session sont aléatoires et imprévisibles
- [ ] Sessions expirées sont rejetées
- [ ] Permissions vérifiées côté serveur pour chaque opération
- [ ] Les erreurs n'exposent pas d'informations sensibles

### Validation de la base de données

- [ ] Schéma SQL respecte le modèle de données
- [ ] Contraintes de clé étrangère sont respectées
- [ ] Transactions sont atomiques (tout ou rien)
- [ ] Index sont utilisés pour les requêtes fréquentes
- [ ] Connexions sont correctement gérées (pool, fermeture)

### Validation des fichiers

- [ ] Fichiers sont stockés avec le nom généré par le serveur
- [ ] Métadonnées sont correctement persistées
- [ ] SHA-256 est vérifié après transfert
- [ ] Fichiers trop volumineux sont rejetés
- [ ] Types MIME non autorisés sont rejetés

### Validation des notifications

- [ ] Événements sont transmis en temps réel sur connexion active
- [ ] Notifications persistées sont récupérées après reconnexion
- [ ] Acquittement marque les notifications comme lues
- [ ] Doublons d'événements sont gérés (idempotence)
- [ ] Notifications sont filtrées par utilisateur destinataire

---

# 19. CONCLUSION

N.O.H. CloudMesh est conçu comme une plateforme locale de gestion et de suivi des demandes administratives universitaires.

Son architecture centralisée repose sur des clients Flutter, un serveur Dart et une base PostgreSQL. La communication entre les composants est assurée par un protocole applicatif utilisant TCP et des messages JSON structurés.

La solution vise à améliorer la visibilité sur le traitement des demandes, à renforcer leur traçabilité et à réduire la nécessité pour les étudiants de solliciter directement les services administratifs pour connaître leur état d'avancement.

Cette spécification constitue le document de référence pour la conception détaillée, le développement, l'intégration et la validation du MVP.