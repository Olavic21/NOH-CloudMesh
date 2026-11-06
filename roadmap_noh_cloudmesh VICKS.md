# Roadmap technique personnelle — N.O.H. CloudMesh

**Responsable :** OLAMA Victoire Aimé (Vick) — Backend Dart, communication TCP, `common/`
**Équipe G4 :** Abdourahim (Frontend Flutter), Habiba (Infrastructure EVE-NG, PostgreSQL)
**Période :** 4 semaines, du mercredi 4 novembre 2026 au vendredi 27 novembre 2026 (démonstrations les vendredis 6, 13, 20 et 27 novembre)

> **Convention.** Les éléments marqués **[DOC]** viennent des deux guides fournis. Les éléments marqués **[REC]** sont mes recommandations techniques, à valider. Les identifiants de backlog (S1-01 à S4-08) n'ayant pas été fournis, toutes les tâches portent un identifiant **provisoire** `P-xx`, à remplacer par les vrais identifiants dès que le tableau de bord est disponible.

---

## 1. Analyse de mes responsabilités

| Domaine | Dossier | Rôle | Reviewer principal |
|---|---|---|---|
| Backend Dart | `server/` | Serveur TCP, logique métier, accès PostgreSQL, authentification | Moi |
| Communication TCP | `server/` + `common/` | Sockets, framing, gestion des clients | Moi |
| Protocole partagé | `common/` | Format JSON, framing, modèles, codes d'erreur | Moi, validé par les trois membres **[DOC]** |

**Points d'attention [DOC]**
- Toute modification de `common/` passe par une PR courte, annoncée dans le canal d'équipe avant fusion (R5), et relue par les trois membres.
- Je ne modifie que les fichiers de ma tâche (R6). Une modification hors périmètre se signale dans la PR.
- Je ne pousse jamais directement sur `main` ni `dev` (R1), et je n'utilise jamais `--force` sur ces branches (R4).

Ma mission n'est pas seulement d'écrire le code : je dois pouvoir expliquer et défendre chaque composant devant l'enseignant.

---

## 2. Compétences actuelles et compétences à acquérir

**Acquis supposés (à confirmer par un test de départ de 30 minutes) :** bases de la programmation orientée objet, notions de réseau (modèle OSI, adresse IP, port), SQL de base, utilisation de Git en ligne de commande.

**À acquérir, par ordre de priorité :**

1. **Dart asynchrone** : `Future`, `async`/`await`, `Stream`, `StreamSubscription`, `StreamController`. Indispensable car tout le réseau est asynchrone.
2. **TCP en pratique** : flux d'octets, framing, gestion des déconnexions, half-close, timeouts.
3. **Sockets Dart** : `ServerSocket`, `Socket`, `Socket.listen`, `utf8`/`dart:convert`.
4. **Protocole JSON à longueur préfixée** : lecture d'octets, reconstruction de trames incomplètes, gestion des trames malformées.
5. **PostgreSQL + paquet `postgres`** : connexion, requêtes paramétrées, transactions.
6. **Sécurité de base** : hachage de mots de passe, validation des entrées, secrets hors dépôt, TLS (conceptuel au prototype).
7. **Tests** : `package:test`, tests unitaires du framing, tests d'intégration client/serveur.
8. **Outils réseau** : Netcat, Wireshark (filtre `tcp.port == …`), EVE-NG pour la topologie.

---

## 3. Architecture cible de mon périmètre

```
 Flutter (Android/Windows)                         Ubuntu Server 24.04 (EVE-NG)
 ┌────────────────────────┐   TCP + trame JSON    ┌──────────────────────────────┐
 │ client/ (Abdourahim)   │ ───────────────────▶  │ server/ Dart (moi)           │
 │  utilise common/       │ ◀───────────────────  │  ServerSocket → Connexions   │
 └────────────────────────┘                       │  Dispatcher → Services       │
                                                  │  Repositories (postgres)     │
 common/ (moi)  : framing, modèles, erreurs,      └──────────────┬───────────────┘
                  sérialisation JSON                             │ SQL (interne uniquement)
                                                  ┌──────────────▼───────────────┐
                                                  │ PostgreSQL (schéma : Habiba) │
                                                  └──────────────────────────────┘
```

**Structure de fichiers proposée (`server/`)** — à valider avec Habiba et Abdourahim :

```
server/
  bin/server.dart            point d'entrée
  lib/src/config.dart        configuration (port, DB) lue depuis l'environnement
  lib/src/net/connection.dart   une connexion client (lecture de trames, timeouts)
  lib/src/net/server.dart       ServerSocket, acceptation, registre des clients
  lib/src/dispatch/router.dart  routage par type de message
  lib/src/services/            auth_service.dart, … (logique métier)
  lib/src/db/                  connexion PostgreSQL, repositories
  lib/src/log/                 journalisation (package logging)
  test/                        tests unitaires et d'intégration

common/
  lib/framing.dart           encodage/décodage à préfixe de longueur
  lib/protocol.dart          types de messages, identifiants, codes d'erreur
  lib/models/                modèles JSON partagés
  test/                      tests du framing et de la validation
```

---

## 4. Roadmap générale (4 semaines)

| Semaine | Dates | Thème | Livrable de fin de semaine | Démonstration |
|---|---|---|---|---|
| S1 | 4 – 8 nov. | Dart, TCP, premier serveur écho | Serveur TCP testé avec Netcat, framing v0 | Vendredi 6 nov. |
| S2 | 9 – 15 nov. | Protocole `common/`, connexions multiples, PostgreSQL | Protocole JSON v1 validé avec Abdourahim, connexion DB | Vendredi 13 nov. |
| S3 | 16 – 22 nov. | Authentification, services, intégration Flutter | Login fonctionnel de bout en bout, tests d'intégration | Vendredi 20 nov. |
| S4 | 23 – 27 nov. | Sécurité, EVE-NG, rapport, stabilisation | Serveur déployé sur Ubuntu, rapport de tests, PR vers `main` | Vendredi 27 nov. |

**Charge réaliste :** le périmètre est dense pour quatre semaines. Les priorités sont données en section 10 (risques), avec ce qui peut être reporté sans bloquer l'équipe.

---

## 5. Planning détaillé semaine par semaine

### Semaine 1 — Dart et premier serveur TCP (4 – 8 nov.)

**Objectif pédagogique :** comprendre les Futures, les Streams et les sockets.
**Objectif technique :** un serveur TCP qui accepte des connexions et renvoie ce qu'il reçoit.

- Lun. 4 : environnement (VS Code, Flutter SDK, Dart, Git), clonage du dépôt, `git checkout dev`, création de `feat/P-01-setup-serveur`.
- Mar. 5 : Dart (async/await, Stream), exercices sur `Stream` et `Future.delayed`.
- Mer. 6 : **Démonstration** du serveur écho ; premier test avec `nc localhost 4000`.
- Jeu. 7 : gestion des connexions multiples, déconnexions, `onError`/`onDone`.
- Ven. 8 : premiers tests `package:test`, PR vers `dev`, revue.

### Semaine 2 — Protocole, multi-clients, base de données (9 – 15 nov.)

**Objectif pédagogique :** concevoir un protocole, et comprendre TCP comme flux.
**Objectif technique :** `common/` v1, serveur multi-clients, connexion PostgreSQL.

- Lun. 9 : atelier protocole avec Abdourahim (format des trames, types de messages, codes d'erreur). Voir section 8.
- Mar. 10 : implémentation du framing à préfixe de longueur dans `common/`, tests unitaires.
- Mer. 11 : gestion des trames incomplètes et malformées, tests.
- Jeu. 12 : connexion PostgreSQL (paquet `postgres`), tests avec Habiba sur le schéma.
- Ven. 13 : **Démonstration** : deux clients simultanés, échange de messages JSON, requête SQL simple.

### Semaine 3 — Authentification et intégration Flutter (16 – 22 nov.)

**Objectif pédagogique :** sécuriser les mots de passe, valider les entrées.
**Objectif technique :** login/inscription fonctionnels avec le client Flutter.

- Lun. 16 : modèle `users` avec Habiba, hachage (validation du paquet `bcrypt` ou `crypto`) **[REC]**.
- Mar. 17 : service d'authentification, sessions simples (jeton par connexion) **[REC]**.
- Mer. 18 : routage des requêtes et codes d'erreur, aucune fuite d'information.
- Jeu. 19 : tests d'intégration avec le client Flutter d'Abdourahim.
- Ven. 20 : **Démonstration** : connexion depuis l'application Flutter sur émulateur Android.

### Semaine 4 — Sécurité, déploiement et livrables (23 – 27 nov.)

**Objectif pédagogique :** déployer et documenter.
**Objectif technique :** serveur sur Ubuntu Server, rapport de tests, PR de fin de sprint.

- Lun. 23 : configuration Ubuntu, service systemd, avec Habiba (fichiers dans `infra/`).
- Mar. 24 : pare-feu UFW, restriction de PostgreSQL au serveur applicatif, validation des ports.
- Mer. 25 : tests depuis le LAN, capture Wireshark, rapport de tests.
- Jeu. 26 : stabilisation, correction des derniers bugs, relecture croisée des PR.
- Ven. 27 : **Démonstration finale** et PR `dev` → `main`, validée par les trois membres.

---

## 6. Planning quotidien et backlog personnel

Les identifiants sont provisoires (`P-xx`). Difficulté : F (facile), M (moyenne), D (difficile). Durées en heures.

| # | Tâche (ID provisoire) | Domaine | Branche | Diff. | Durée | Dépend de |
|---|---|---|---|---|---|---|
| 1 | P-01 Environnement et premier clone | Tous | `docs/P-01-setup` | F | 2 h | — |
| 2 | P-02 Serveur écho TCP | server | `feat/P-02-echo-tcp` | M | 4 h | 1 |
| 3 | P-03 Gestion multi-clients et déconnexions | server | `feat/P-03-multi-clients` | M | 4 h | 2 |
| 4 | P-04 Tests `package:test` du serveur écho | server | `test/P-04-echo-tests` | F | 2 h | 2 |
| 5 | P-05 Atelier protocole avec Abdourahim | common (doc) | `docs/P-05-protocole` | M | 2 h | — |
| 6 | P-06 Framing à préfixe de longueur | common | `feat/P-06-framing` | D | 6 h | 5 |
| 7 | P-07 Trames incomplètes et malformées | common | `fix/P-07-trames` | D | 4 h | 6 |
| 8 | P-08 Modèles JSON et codes d'erreur | common | `feat/P-08-modeles` | M | 4 h | 5 |
| 9 | P-09 Routeur de messages | server | `feat/P-09-routeur` | M | 3 h | 6, 8 |
| 10 | P-10 Connexion PostgreSQL | server/db | `feat/P-10-postgres` | M | 4 h | Habiba (schéma) |
| 11 | P-11 Repository utilisateurs (CRUD) | server | `feat/P-11-users-repo` | M | 4 h | 10 |
| 12 | P-12 Hachage des mots de passe | server | `feat/P-12-hachage` | M | 3 h | 11 |
| 13 | P-13 Service d'authentification | server | `feat/P-13-auth` | D | 6 h | 9, 12 |
| 14 | P-14 Journalisation (`logging`) | server | `feat/P-14-logs` | F | 2 h | 2 |
| 15 | P-15 Tests d'intégration client/serveur | tests | `test/P-15-integration` | D | 4 h | 13, Flutter |
| 16 | P-16 Configuration Ubuntu et systemd | infra | `feat/P-16-systemd` | M | 3 h | Habiba |
| 17 | P-17 Pare-feu et restriction PostgreSQL | infra | `feat/P-17-pare-feu` | M | 2 h | 16 |
| 18 | P-18 Capture Wireshark et rapport de tests | docs | `docs/P-18-rapport` | M | 4 h | 15, 17 |
| 19 | P-19 Documentation technique du protocole | docs | `docs/P-19-protocole-doc` | M | 3 h | 8 |

**Ordre d'exécution recommandé :** 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 15 → 16 → 17 → 18 → 19.

---

## 7. Mise en œuvre pas à pas : le protocole de base

Cette section donne les étapes, sans bloc de code complet, pour que je code moi-même.

**Décisions à prendre et valider avec Abdourahim (non tranchées par les documents) :**
1. Taille du préfixe de longueur : 4 octets big-endian est un choix courant **[REC]**.
2. Taille maximale d'une trame, pour se protéger contre les messages démesurés **[REC]**.
3. Encodage : UTF-8 uniquement, JSON en objet racine **[REC]**.
4. Structure commune : `{ "id": <int>, "type": "<string>", "payload": {…} }` **[REC]**.
5. Format des réponses : `{ "id": <int>, "ok": true|false, "payload" | "error": {…} }` **[REC]**.
6. Liste des types de messages et des codes d'erreur : **à définir ensemble, rien n'est encore fixé.**

**Étapes d'implémentation :**
1. Écrire le framing comme une fonction qui prend un flux d'octets et produit des trames complètes.
2. Tester avec des trames coupées en plusieurs morceaux, et plusieurs trames collées.
3. Ajouter le décodage JSON, avec gestion d'erreur sans interrompre la connexion.
4. Rejeter une trame trop grande en fermant proprement la connexion.

**Défi pour valider ta compréhension :** si un client envoie les octets d'une trame en trois paquets TCP distincts, à quel moment ton code produit-il le message ? Explique sans regarder le code.

---

## 8. Coordination avec l'équipe

### Avec Abdourahim (Frontend Flutter)
| Moment | Sujet | Ce que je fournis | Ce que je reçois |
|---|---|---|---|
| Lun. 9 nov. | Protocole JSON et framing | Proposition de format (section 7) | Contraintes côté Flutter (lecture de flux, `Socket` Dart) |
| Mer. 11 nov. | Gestion des erreurs | Liste des codes d'erreur | Cas d'erreur à afficher à l'utilisateur |
| Ven. 20 nov. | Test de login | Serveur lancé, adresse et port, exemples de trames | Retour sur les erreurs et les timeouts |

### Avec Habiba (Infrastructure EVE-NG)
| Moment | Sujet | Ce que je fournis | Ce que je reçois |
|---|---|---|---|
| Jeu. 12 nov. | Schéma PostgreSQL | Liste des entités et requêtes prévues | Schéma SQL et script de données |
| Lun. 23 nov. | Ubuntu Server et systemd | Commande de lancement, variables d'environnement (sans secrets) | Accès SSH, nom de la machine, port ouvert |
| Mar. 24 nov. | Pare-feu et accès PostgreSQL | Ports TCP à ouvrir, IP du serveur applicatif | Règles UFW appliquées |
| Mer. 25 nov. | Tests sur EVE-NG | Scénarios de test, critères de réussite | Résultats depuis un client du LAN |

---

## 9. Matrice des tests et critères d'acceptation

| Composant | Test | Critère de réussite | Outil |
|---|---|---|---|
| Framing | Trame coupée en 3 morceaux | Un seul message reconstruit | `dart test` |
| Framing | Deux trames dans un même paquet | Deux messages distincts | `dart test` |
| Framing | Trame > taille maximale | Connexion fermée proprement | `dart test` |
| JSON | Message malformé | Erreur renvoyée, serveur toujours actif | `dart test` |
| Serveur | Deux clients simultanés | Réponses correctes sans mélange | `dart test` + Netcat |
| Serveur | Déconnexion brutale | Ressources libérées, log écrit | Test manuel + logs |
| Auth | Mot de passe mal saisi | Erreur générique, aucun détail révélé | Test d'intégration |
| Auth | Base de données : mot de passe stocké | Aucun mot de passe en clair | Requête SQL (DBeaver) |
| Réseau | Port fermé par le pare-feu | Connexion refusée depuis le LAN | Netcat |
| Réseau | Échange de messages | Trames visibles et conformes | Wireshark |
| Intégration | Login depuis Flutter | Succès et échec gérés | Émulateur Android |

**Critère général pour toute tâche :** les tests passent, la PR est relue, le critère d'acceptation du backlog est coché. Une tâche n'est jamais « terminée » simplement parce que le code semble correct.

---

## 10. Risques techniques et solutions préventives

| Risque | Impact | Prévention |
|---|---|---|
| Protocole mal défini | Retards importants côté Flutter | Atelier du 9 nov., document `docs/protocole.md` signé par les trois |
| Trames mal découpées | Bugs intermittents difficiles à reproduire | Tests dès la semaine 2 avec découpages aléatoires |
| Bloquant sur le framing | Semaine 2 retardée | Commencer par une version simple, durcir ensuite |
| Mot de passe mal haché | Faille de sécurité | Paquet validé avant usage, aucun stockage en clair |
| Surcharge de la semaine 3 | Authentification incomplète | Priorité : login seul. Inscription et sessions avancées reportées |
| TCP non chiffré | Mots de passe lisibles sur le réseau | Prototype en LAN isolé, TLS documenté comme étape suivante |
| Conflits sur `common/` | Protocole incohérent | PR courtes, annonce préalable, relecture des trois |
| Backlog incomplet | Mauvaise répartition | Demander le tableau de bord avant le 6 nov. |

**Priorités si le temps manque :** 1) serveur TCP fonctionnel, 2) framing fiable, 3) login, 4) PostgreSQL, 5) déploiement Ubuntu, 6) TLS et sécurité avancée (documentés si non réalisés).

---

## 11. Informations manquantes

- Tableau de bord complet avec les identifiants S1-01 à S4-08 et leurs intitulés.
- Liste des fonctionnalités métier du backend (le guide mentionne des « demandes » et des statuts, mais le périmètre n'est pas détaillé).
- Spécification du protocole JSON : aucune n'est fournie, tout doit être validé.
- Schéma PostgreSQL de Habiba.
- Confirmation de la taille du préfixe de longueur et des codes d'erreur.

---

## 12. Checklist finale avant la démonstration

- [ ] Dépôt cloné, branche `dev` à jour, aucune modification sur `main`.
- [ ] Tous les tests passent (`dart test` dans `server/` et `common/`).
- [ ] Aucun secret commité (`.env` dans `.gitignore`), vérifié avec `git log -p | grep -i password`.
- [ ] Protocole documenté dans `docs/` et accepté par Abdourahim.
- [ ] Serveur lancé et joignable depuis un client du LAN.
- [ ] Captures Wireshark et résultats de Netcat prêts.
- [ ] Tableau de bord à jour (statuts : À faire, En cours, En revue, Terminé, Bloqué).
- [ ] PR ouvertes, relues, et la checklist du reviewer complétée.
- [ ] Je peux expliquer le chemin d'une requête, du client Flutter jusqu'à PostgreSQL, sans notes.

---

## Annexe — Workflow Git quotidien (rappel [DOC])

```
git checkout dev && git pull origin dev
git checkout -b feat/P-06-framing            # une branche par tâche
# … coder, tester, committer toutes les 1 à 2 h …
git commit -m "feat(common) : ajoute le framing à préfixe de longueur"
git fetch origin && git rebase origin/dev    # chaque matin
git push --force-with-lease origin feat/P-06-framing
# PR vers dev, titre : [P-06] Framing TCP
```

Les messages de commit suivent Conventional Commits : `feat(server)`, `fix(common)`, `test(server)`, `docs`, `database`, `infra`.
