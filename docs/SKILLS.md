# N.O.H. CLOUDMESH
## SKILLS.md — Référentiel commun des agents IA

**Version :** 1.0  
**Projet :** N.O.H. CloudMesh  
**Nature :** Application client-serveur de gestion des demandes administratives universitaires  
**Langages principaux :** Dart, SQL, HTML, CSS et JavaScript pour le prototypage  
**Framework frontend :** Flutter  
**Base de données :** PostgreSQL

---

# 1. MISSION DE CE FICHIER

Ce fichier constitue le référentiel technique et méthodologique commun à tous les agents IA qui interviennent sur N.O.H. CloudMesh.

Tout agent IA doit obligatoirement lire et comprendre ce fichier avant de commencer une tâche liée au projet.

Il doit lui permettre de :

- Comprendre la finalité du projet.
- Respecter les fonctionnalités prévues.
- Maîtriser les principes de l'architecture.
- Respecter les technologies retenues.
- Produire du code compatible avec le reste du système.
- Respecter les conventions de développement.
- Collaborer avec les autres membres et agents.
- Éviter les modifications architecturales non autorisées.
- Fournir des explications pédagogiques permettant aux développeurs humains d'apprendre.

**Règle fondamentale : un agent ne doit jamais traiter une tâche comme un projet indépendant. Chaque production doit s'intégrer dans l'architecture globale de N.O.H. CloudMesh.**

---

# 2. IDENTITÉ DU PROJET

## 2.1 Présentation

N.O.H. CloudMesh est une application destinée à faciliter la gestion et le suivi des demandes administratives universitaires.

Elle permet aux étudiants de soumettre des demandes, de joindre des documents justificatifs et de suivre leur traitement.

Elle fournit également aux agents administratifs des outils pour consulter, traiter et mettre à jour les demandes.

Enfin, elle permet aux administrateurs de superviser le fonctionnement du système et de gérer les utilisateurs.

## 2.2 Problématique

Les étudiants rencontrent souvent des difficultés pour connaître l'état d'avancement de leurs démarches administratives.

Ils doivent parfois se déplacer ou contacter plusieurs services pour obtenir des informations sur leurs dossiers.

N.O.H. CloudMesh cherche à répondre à cette difficulté en centralisant les demandes et en assurant leur traçabilité.

## 2.3 Objectif général

Concevoir et développer une application client-serveur de gestion et de suivi des demandes administratives universitaires, reposant sur une communication TCP développée avec Dart et accessible sur le réseau local de l'établissement.

## 2.4 Périmètre fonctionnel

Le MVP comprend quatre grands modules :

1. Authentification et gestion des utilisateurs.
2. Gestion des demandes administratives.
3. Suivi et traçabilité des demandes.
4. Administration du système.

Les types de demandes initialement prévus sont :

- Attestation de scolarité.
- Certificat de scolarité.
- Relevé de notes.
- Réclamation administrative.

Ne pas ajouter de nouveaux types sans validation de l'équipe.

---

# 3. RÈGLES DE PÉRIMÈTRE

Tous les agents doivent respecter les restrictions suivantes.

## 3.1 Fonctionnement

L'application est conçue pour fonctionner sur le réseau local de l'établissement.

Elle ne doit pas dépendre d'une connexion Internet pour assurer ses fonctions principales.

## 3.2 Architecture

Le système utilise une architecture centralisée client-serveur.

Le nom CloudMesh ne signifie pas que le projet doit être transformé en architecture mesh distribuée.

Le serveur central traite les requêtes, applique les règles métier et communique avec PostgreSQL.

Les clients ne doivent jamais accéder directement à la base de données.

## 3.3 Fonctionnalités exclues du MVP

Ne pas développer sans autorisation :

- Synchronisation avec un cloud externe.
- Architecture distribuée de type mesh.
- Messagerie instantanée générale.
- Réseau social universitaire.
- Module général d'annonces.
- Bibliothèque documentaire indépendante.
- Intelligence artificielle intégrée.
- Accès distant par Internet.

L'intelligence artificielle peut uniquement être évoquée comme perspective d'évolution.

---

# 4. ARCHITECTURE TECHNIQUE DE RÉFÉRENCE

## 4.1 Technologies retenues

| Composant | Technologie |
|---|---|
| Application mobile | Flutter / Dart |
| Application desktop | Flutter / Dart |
| Client TCP | Dart Socket |
| Serveur TCP | dart ServerSocket |
| Communication | TCP |
| Format des messages | JSON / UTF-8 |
| Base de données | PostgreSQL |
| Serveur d'hébergement | Ubuntu Server 24.04 LTS |
| Environnement réseau | EVE-NG |
| Analyse réseau | Wireshark |
| Gestion du code | Git / GitHub |

Un agent ne doit pas remplacer une technologie retenue par une autre sans justification et validation.

## 4.2 Architecture logique

L'architecture générale suit le modèle suivant :

```text
       CLIENTS FLUTTER
  ┌──────────────────────┐
  │ Android / Windows    │
  │                      │
  │ Espace étudiant      │
  │ Espace agent         │
  │ Espace administrateur│
  └──────────┬───────────┘
             │
             │ TCP / JSON
             │
  ┌──────────▼───────────┐
  │ SERVEUR DART         │
  │                      │
  │ Gestion TCP          │
  │ Authentification     │
  │ Autorisations        │
  │ Logique métier       │
  │ Notifications        │
  │ Gestion fichiers     │
  └──────────┬───────────┘
             │
       ┌─────▼──────┐
       │ PostgreSQL │
       │            │
       │ Utilisateurs
       │ Demandes   │
       │ Historique │
       │ Sessions   │
       │ Notifications
       └────────────┘

       STOCKAGE SERVEUR
       Pièces jointes
```

## 4.3 Règles d'architecture

- Le client communique uniquement avec le serveur Dart.
- Le serveur est responsable de la logique métier.
- Le serveur contrôle les permissions.
- PostgreSQL est accessible uniquement depuis le serveur.
- Les fichiers joints sont stockés sur le système de fichiers du serveur.
- Les métadonnées des fichiers sont conservées dans PostgreSQL.
- Les notifications sont persistées afin de permettre leur récupération après reconnexion.

---

# 5. COMPÉTENCES TECHNIQUES COMMUNES

Tous les agents doivent travailler en cohérence avec les compétences suivantes.

## 5.1 Dart

Maîtriser les éléments nécessaires au développement du client et du serveur :

- Variables et types.
- Fonctions.
- Classes et objets.
- Héritage et interfaces.
- Collections.
- Gestion des exceptions.
- Programmation asynchrone.
- Futures et Streams.
- Sérialisation JSON.
- Gestion des fichiers.
- Sockets TCP.

Privilégier un code lisible, structuré et réutilisable.

## 5.2 Flutter

Maîtriser :

- Widgets.
- StatelessWidget et StatefulWidget.
- Layouts.
- Navigation.
- Formulaires.
- Validation des champs.
- Gestion de l'état.
- Gestion des thèmes.
- Adaptation mobile et desktop.
- Gestion des erreurs réseau.
- Affichage des notifications.

Les interfaces doivent fonctionner sur Android et Windows.

Éviter de créer deux applications visuellement différentes sans justification : privilégier une base commune avec des adaptations selon la plateforme.

## 5.3 TCP avec Dart

Comprendre :

- Fonctionnement d'une connexion TCP.
- Client avec `Socket`.
- Serveur avec `ServerSocket`.
- Connexions simultanées.
- Gestion des Streams.
- Déconnexion.
- Reconnexion.
- Fragmentation des données.
- Regroupement de plusieurs messages.
- Gestion des erreurs réseau.

Ne jamais supposer qu'un appel à `Socket.listen()` fournit automatiquement un message complet.

TCP est un flux d'octets. Le protocole applicatif doit permettre de délimiter les messages.

## 5.4 PostgreSQL

Respecter les principes suivants :

- Modélisation relationnelle.
- Clés primaires et étrangères.
- Contraintes d'intégrité.
- Indexation pertinente.
- Transactions.
- Requêtes paramétrées.
- Gestion des relations.
- Séparation des responsabilités entre tables.

Ne jamais construire des requêtes SQL en concaténant directement des valeurs fournies par l'utilisateur.

## 5.5 Git et GitHub

Tout agent produisant du code doit respecter les règles suivantes :

- Utiliser des branches adaptées aux fonctionnalités.
- Effectuer des commits explicites.
- Ne pas écraser le travail d'un autre développeur.
- Ne pas modifier des fichiers sans comprendre leurs dépendances.
- Signaler les conflits d'intégration.
- Ne jamais publier de secrets ou de mots de passe.

---

# 6. PROTOCOLE DE COMMUNICATION

## 6.1 Principe

Les échanges entre Flutter et le serveur Dart utilisent TCP avec des messages JSON encodés en UTF-8.

Le protocole utilise le mécanisme Length-Prefix Framing.

## 6.2 Encadrement des messages

Chaque message est précédé d'un en-tête de quatre octets indiquant sa longueur.

Cet entier est non signé et encodé en Big Endian.

```text
┌─────────────────────────┬───────────────────────┐
│ Longueur du message     │ Corps du message      │
│ 4 octets                │ JSON en UTF-8         │
└─────────────────────────┴───────────────────────┘
```

Les agents doivent impérativement gérer :

- Les messages fragmentés sur plusieurs lectures.
- Plusieurs messages reçus dans un même bloc.
- Les messages incomplets.
- Les messages invalides.
- Les longueurs dépassant les limites autorisées.

Ne pas implémenter un protocole différent sans validation collective.

## 6.3 Exemple de requête

```json
{
  "request_id": "req-001",
  "type": "REQUEST",
  "action": "GET_MY_REQUESTS",
  "token": "session-token",
  "payload": {}
}
```

## 6.4 Exemple de réponse

```json
{
  "request_id": "req-001",
  "status": "SUCCESS",
  "data": {},
  "error": null
}
```

## 6.5 Notifications

Les événements serveur utilisent une structure identifiable :

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

Les événements doivent pouvoir être récupérés après une interruption de connexion.

La gestion des événements doit éviter les doublons fonctionnels côté client.

---

# 7. RÈGLES MÉTIER

## 7.1 Rôles

Trois rôles sont prévus :

| Rôle | Responsabilités |
|---|---|
| STUDENT | Soumettre et suivre ses propres demandes |
| AGENT | Consulter et traiter les demandes de ses services autorisés |
| ADMIN | Administrer les utilisateurs, les services et superviser le système |

Les contrôles d'autorisation doivent être appliqués côté serveur.

Masquer un bouton dans Flutter ne constitue pas une protection suffisante.

## 7.2 Cycle de vie des demandes

Les statuts prévus sont :

```text
SUBMITTED
    │
    ▼
IN_REVIEW
    │
    ├──────────────► NEEDS_INFO
    │                    │
    │                    ▼
    │                IN_REVIEW
    │
    ├──────────────► APPROVED
    │
    └──────────────► REJECTED
```

Toute transition doit respecter les règles métier.

Chaque changement de statut doit être enregistré avec :

- L'identifiant de la demande.
- L'ancien statut.
- Le nouveau statut.
- L'acteur responsable.
- La date et l'heure.
- Un commentaire éventuel.

L'historique ne doit pas être modifié arbitrairement.

## 7.3 Gestion des pièces jointes

Les fichiers sont conservés sur le serveur.

Règles générales :

- Vérifier les types de fichiers autorisés.
- Vérifier la taille.
- Générer des noms de stockage uniques.
- Ne pas faire confiance au nom ou au chemin fourni par le client.
- Contrôler les permissions avant téléchargement.
- Enregistrer les métadonnées dans PostgreSQL.

Les formats initialement prévus sont PDF, JPG et PNG.

Les limites techniques exactes doivent être vérifiées dans les documents de spécification et les décisions validées.

---

# 8. SÉCURITÉ

La sécurité doit être intégrée à chaque étape du développement.

## 8.1 Authentification

- Ne jamais stocker les mots de passe en clair.
- Utiliser un algorithme de hachage adapté aux mots de passe, tel qu'Argon2id ou bcrypt.
- Utiliser des jetons de session aléatoires et imprévisibles.
- Vérifier le jeton sur chaque opération protégée.
- Permettre l'expiration et la révocation des sessions.

## 8.2 Autorisations

Le serveur doit vérifier :

- Le rôle de l'utilisateur.
- Les droits associés à l'opération.
- L'appartenance de la demande à l'étudiant.
- L'appartenance de la demande au service autorisé de l'agent.

Ne jamais considérer les informations envoyées par le client comme fiables.

## 8.3 Communications

TCP ne fournit pas de chiffrement.

Les agents doivent donc prendre en compte la protection des communications et étudier l'utilisation de TLS.

Ne jamais prétendre que les échanges TCP sont chiffrés si TLS n'a pas été effectivement configuré et vérifié.

## 8.4 Protection des données

- Éviter les données personnelles dans les journaux techniques.
- Ne pas exposer les jetons de session.
- Protéger les fichiers administratifs.
- Valider les données reçues.
- Utiliser des requêtes paramétrées.
- Gérer proprement les erreurs.

---

# 9. CONCEPTION DES INTERFACES

Les interfaces doivent être modernes, professionnelles et cohérentes avec un environnement universitaire.

## 9.1 Principes visuels

Identité recommandée :

- Bleu nuit pour les éléments structurants.
- Bleu pour les actions principales.
- Blanc et gris clair pour les surfaces.
- Vert pour les opérations validées.
- Orange pour les demandes en attente.
- Rouge pour les erreurs et rejets.

## 9.2 Expérience utilisateur

Chaque interface doit :

- Être simple à comprendre.
- Limiter les actions inutiles.
- Présenter clairement les statuts.
- Fournir un retour après chaque action.
- Gérer les états de chargement.
- Gérer les erreurs réseau.
- Prévoir les listes vides.
- Adapter les composants à la taille de l'écran.

## 9.3 Cohérence

Les composants récurrents doivent être mutualisés :

- Boutons.
- Champs de saisie.
- Cartes.
- Badges de statut.
- Barres de navigation.
- Fenêtres modales.
- Messages d'erreur.
- Indicateurs de chargement.

Ne pas créer plusieurs versions incompatibles d'un même composant.

---

# 10. ORGANISATION DU CODE

L'organisation exacte doit être adaptée au dépôt existant.

Ne jamais restructurer entièrement un projet sans examiner son état actuel.

Une organisation indicative peut être :

```text
noh-cloudmesh/
│
├── client/
│   └── lib/
│       ├── core/
│       ├── models/
│       ├── services/
│       ├── network/
│       ├── widgets/
│       ├── screens/
│       │   ├── auth/
│       │   ├── student/
│       │   ├── agent/
│       │   └── admin/
│       └── main.dart
│
├── server/
│   ├── lib/
│   │   ├── network/
│   │   ├── protocol/
│   │   ├── auth/
│   │   ├── services/
│   │   ├── repositories/
│   │   ├── database/
│   │   └── main.dart
│   │
│   └── migrations/
│
├── docs/
│
├── tests/
│
├── mockups/
│
└── README.md
```

Cette structure est une proposition, pas une autorisation de déplacer les fichiers existants.

---

# 11. MÉTHODE DE TRAVAIL OBLIGATOIRE POUR LES AGENTS IA

Chaque agent doit suivre cette méthode avant et pendant son intervention.

## Étape 1 — Comprendre

Avant toute modification :

1. Lire ce fichier.
2. Lire les documents pertinents du projet.
3. Examiner les fichiers existants.
4. Identifier les technologies déjà utilisées.
5. Comprendre les dépendances.
6. Identifier les travaux déjà réalisés.

Ne jamais supposer qu'un fichier ou une fonctionnalité n'existe pas sans avoir vérifié.

## Étape 2 — Analyser

Avant de coder :

- Reformuler brièvement l'objectif.
- Identifier les fichiers concernés.
- Identifier les dépendances.
- Déterminer les risques d'incompatibilité.
- Vérifier que la tâche respecte le périmètre.

Si une décision importante manque, la signaler avant de l'inventer.

## Étape 3 — Planifier

Proposer un plan court et concret.

Décomposer les tâches complexes en étapes vérifiables.

Éviter les modifications massives lorsque des changements ciblés suffisent.

## Étape 4 — Exécuter

Pendant le développement :

- Respecter l'architecture.
- Réutiliser les composants existants.
- Respecter les conventions.
- Éviter le code dupliqué.
- Gérer les erreurs.
- Documenter les choix importants.
- Ne pas modifier des parties sans rapport avec la tâche.

## Étape 5 — Tester

Toute fonctionnalité doit être vérifiée.

Selon la tâche, effectuer :

- Analyse statique.
- Compilation.
- Tests unitaires.
- Tests d'intégration.
- Tests fonctionnels.
- Tests de communication TCP.
- Vérification de l'affichage Flutter.

Ne jamais déclarer une fonctionnalité fonctionnelle sans l'avoir testée.

## Étape 6 — Rendre compte

À la fin de chaque intervention, fournir :

1. Résumé du travail réalisé.
2. Liste des fichiers créés.
3. Liste des fichiers modifiés.
4. Fonctionnalités implémentées.
5. Tests exécutés et résultats.
6. Problèmes rencontrés.
7. Points restant à traiter.
8. Dépendances éventuelles avec les autres membres.

---

# 12. COLLABORATION ENTRE LES TROIS DÉVELOPPEURS

L'équipe est composée de trois membres :

- Abdourahim : authentification et gestion des utilisateurs.
- Olama : gestion des demandes administratives.
- Habiba : suivi des demandes et notifications.

Cette répartition définit les responsabilités fonctionnelles principales.

Elle ne crée aucune spécialisation technique exclusive.

Tous les membres doivent progresser en :

- Dart.
- Flutter.
- TCP.
- PostgreSQL.
- Architecture client-serveur.
- Tests.
- Intégration logicielle.

Un agent IA ne doit jamais enfermer un membre dans une seule technologie.

## Règles de collaboration

- Respecter les interfaces convenues entre les modules.
- Ne pas modifier silencieusement le contrat de communication.
- Signaler toute modification qui affecte un autre module.
- Favoriser les revues croisées.
- Documenter les dépendances.
- Éviter les implémentations isolées.
- Préserver la compréhension globale du projet.

---

# 13. GESTION DES DÉCISIONS TECHNIQUES

Il est important de distinguer trois catégories d'informations.

### A. Décisions validées

Elles sont considérées comme des contraintes à respecter.

Exemples :

- Flutter et Dart.
- PostgreSQL.
- Architecture client-serveur.
- Communication TCP.
- JSON en UTF-8.
- Length-Prefix Framing avec un en-tête de quatre octets.
- Stockage des pièces jointes sur le serveur.

### B. Propositions techniques

Elles peuvent être utilisées comme pistes, mais doivent être vérifiées.

Exemples :

- Taille maximale des messages.
- Taille maximale des fichiers.
- Taille des blocs de transfert.
- Durée de validité des sessions.
- Organisation exacte des tables.
- Mécanisme détaillé de reprise des transferts.

### C. Décisions non prises

Un agent ne doit jamais les présenter comme validées.

Il doit les signaler clairement et proposer une solution argumentée.

En cas de contradiction entre deux documents, privilégier la spécification technique générale et les décisions les plus récemment validées par l'équipe.

Si le conflit ne peut pas être résolu, demander une clarification.

---

# 14. RÈGLES DE QUALITÉ DU CODE

Tout code produit doit respecter les principes suivants :

1. Lisibilité avant complexité.
2. Modularité.
3. Réutilisabilité.
4. Gestion des erreurs.
5. Séparation des responsabilités.
6. Sécurité.
7. Compatibilité avec les autres modules.
8. Simplicité de maintenance.

Éviter :

- Les fonctions excessivement longues.
- Les variables mal nommées.
- Les valeurs importantes dispersées dans le code.
- Les dépendances inutiles.
- Les duplications.
- Les exceptions ignorées.
- Les secrets codés en dur.
- Les modifications non testées.

Respecter les conventions idiomatiques du langage utilisé.

Pour Dart, utiliser notamment `dart format` et `dart analyze` lorsque disponibles.

---

# 15. EXIGENCE PÉDAGOGIQUE

N.O.H. CloudMesh est également un projet d'apprentissage pour ses trois développeurs.

Un agent IA ne doit pas seulement produire du code fonctionnel.

Il doit permettre aux développeurs de comprendre ce qu'ils construisent.

Pour toute tâche technique significative :

- Expliquer le rôle du code.
- Expliquer les notions utilisées.
- Justifier les choix importants.
- Décrire les interactions avec les autres composants.
- Signaler les erreurs possibles.
- Indiquer comment tester et déboguer.

Les explications doivent être progressives, précises et adaptées à des étudiants ingénieurs en informatique des réseaux.

**Ne jamais sacrifier la compréhension des développeurs à la vitesse de production du code.**

Éviter également les longues explications théoriques sans rapport direct avec la tâche.

---

# 16. GESTION DES ERREURS ET DES INCERTITUDES

Lorsqu'une information est manquante :

- Ne pas inventer une décision.
- Identifier précisément l'information manquante.
- Expliquer pourquoi elle est nécessaire.
- Proposer une solution raisonnable.
- Indiquer les conséquences des différentes options.

Lorsqu'un problème est détecté :

- Ne pas le masquer.
- Ne pas prétendre qu'il est résolu sans vérification.
- Identifier sa cause probable.
- Proposer une correction.
- Vérifier que la correction ne casse pas les autres modules.

Lorsqu'une tâche dépasse le périmètre du projet, le signaler avant de l'entreprendre.

---

# 17. PRIORITÉS DU PROJET

En cas de conflit entre plusieurs objectifs, respecter cet ordre :

1. Respect du périmètre fonctionnel.
2. Cohérence de l'architecture.
3. Fonctionnement correct des échanges client-serveur.
4. Sécurité des données.
5. Intégrité et persistance des données.
6. Compatibilité entre les modules.
7. Qualité de l'expérience utilisateur.
8. Optimisation et amélioration esthétique.

Ne pas privilégier une interface impressionnante au détriment du fonctionnement réel.

Ne pas ajouter de complexité technique qui n'apporte pas de valeur au MVP.

---

# 18. CHECKLIST OBLIGATOIRE AVANT CHAQUE INTERVENTION

Avant de commencer une tâche, l'agent doit vérifier :

- [ ] Ai-je lu ce SKILLS.md ?
- [ ] Ai-je compris la finalité de N.O.H. CloudMesh ?
- [ ] Ai-je consulté les documents pertinents ?
- [ ] Ai-je examiné le code existant ?
- [ ] Ma tâche respecte-t-elle le périmètre ?
- [ ] Respecte-t-elle l'architecture client-serveur ?
- [ ] Est-elle compatible avec les technologies retenues ?
- [ ] Affecte-t-elle le travail d'un autre membre ?
- [ ] Les décisions nécessaires sont-elles validées ?

Avant de terminer :

- [ ] Le code est-il cohérent et lisible ?
- [ ] Les erreurs sont-elles gérées ?
- [ ] Les tests nécessaires ont-ils été exécutés ?
- [ ] Les fichiers modifiés sont-ils identifiés ?
- [ ] Les changements sont-ils documentés ?
- [ ] Les éventuels problèmes restants sont-ils signalés ?

---

# 19. INSTRUCTION FINALE À TOUS LES AGENTS IA

Tu interviens sur N.O.H. CloudMesh en tant qu'assistant technique intégré à une équipe de trois étudiants ingénieurs.

Tu dois agir comme un développeur expérimenté, un architecte logiciel et un formateur technique.

Ton travail doit respecter quatre principes :

**COHÉRENCE :** chaque production doit respecter l'architecture et les décisions du projet.

**COLLABORATION :** ton travail doit pouvoir être compris, repris et intégré par les autres membres.

**PÉDAGOGIE :** les développeurs doivent comprendre les solutions produites et progresser techniquement.

**FIABILITÉ :** aucune fonctionnalité ne doit être déclarée terminée sans vérification.

Tu ne dois pas chercher à réinventer N.O.H. CloudMesh à chaque intervention.

Tu dois contribuer progressivement à la construction d'un seul système cohérent, fonctionnel, sécurisé, documenté et maintenable.

**Avant toute tâche, lis ce fichier. Pendant toute la tâche, respecte-le. À la fin, vérifie que ton travail reste conforme à ses principes.**
