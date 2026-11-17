# Protocole JSON v1 — N.O.H. CloudMesh

**Statut :** accepté par Abdourahim (frontend) sur la base du compte rendu de l'atelier du 6 novembre 2026. Validation finale par Habiba (réseau) et Olama à compléter (section 8).
**Domaine :** `common/` (règle R5 : relecture par les trois membres avant fusion)
**Source :** `docs/atelier-protocole.md`

---

## 1. Principe

Le client Flutter et le serveur Dart échangent des messages **JSON** sur une connexion **TCP**. TCP transporte un flux d'octets : le protocole définit donc où commence et où finit chaque message.

---

## 2. Délimitation des messages

- Un message est un objet JSON **compact sur une seule ligne**, terminé par `LF` (`0x0A`).
- L'émetteur n'écrit jamais de saut de ligne brut dans un message. Les sauts de ligne des textes sont échappés (`\n`). `jsonEncode` respecte cette règle.
- Le récepteur accumule les octets jusqu'au `LF`. Un message peut arriver en plusieurs morceaux, ou plusieurs messages dans un même morceau.
- Un `\r` juste avant le `LF` est retiré (compatibilité Windows).
- Encodage : **UTF-8** uniquement.
- **Taille maximale : 1 Mo** (1 048 576 octets), `LF` non compris. Au-delà : erreur `FRAME_TOO_LARGE`, puis fermeture de la connexion.

---

## 3. Structure d'un message

La racine de chaque message est un **objet** JSON.

### 3.1 Requête (client → serveur)

```json
{"id": 42, "type": "auth.login", "payload": {"login": "...", "password": "..."}}
```

| Champ | Type | Obligatoire | Rôle |
|---|---|---|---|
| `id` | entier | oui | Relie la réponse à la requête. Unique **par connexion**. |
| `type` | chaîne | oui | Action demandée, convention `domaine.action` |
| `payload` | objet | non | Données propres à l'action |

### 3.2 Réponse (serveur → client)

Succès :

```json
{"id": 42, "ok": true, "payload": {"token": "..."}}
```

Échec :

```json
{"id": 42, "ok": false, "error": {"code": "AUTH_INVALID", "message": "Identifiants incorrects"}}
```

**Règle de sécurité :** `error.message` est destiné à l'utilisateur. Il ne contient jamais de détail interne : requête SQL, nom de table, trace d'exception.

### 3.3 Corrélation

Plusieurs requêtes peuvent être envoyées sans attendre les réponses. Le client relie chaque réponse à sa requête grâce à `id`.

---

## 4. Délais

- **Délai côté client :** 15 secondes sans réponse. Au-delà, la requête est considérée comme échouée.

---

## 5. Comportements du serveur

| Cas | Comportement |
|---|---|
| JSON invalide | Réponse `BAD_REQUEST`, connexion conservée |
| Requête sans `id` | Réponse avec le code noté à l'atelier (voir section 7, point 1), connexion conservée |
| Type inconnu | Réponse `UNKNOWN_TYPE`, connexion conservée |
| Message au-delà de 1 Mo | Réponse `FRAME_TOO_LARGE`, puis fermeture |
| Plusieurs clients simultanés | Chaque connexion est traitée indépendamment |

---

## 6. Notifications serveur

**Non implémentées en v1.** Le format est réservé pour les mises à jour futures : un message envoyé par le serveur sans requête préalable, avec `"id": null` et un type préfixé `event.` :

```json
{"id": null, "type": "event.update", "payload": {}}
```

Côté client, tout message dont `id` est `null` est traité comme un événement, et non comme une réponse.

---

## 7. Types de messages et codes d'erreur

### 7.1 Types

| Type | Sens | Description | Semaine |
|---|---|---|---|
| `echo` | Client → serveur | Renvoie le `payload` tel quel. Test de connexion. | S1 |
| `auth.register` | Client → serveur | Création d'un compte | S3 |
| `auth.login` | Client → serveur | Connexion, retourne un jeton | S3 |
| `auth.logout` | Client → serveur | Déconnexion | S3 |

Les types supplémentaires seront ajoutés après validation des écrans de l'application Flutter.

### 7.2 Codes d'erreur

| Code | Signification | Message utilisateur |
|---|---|---|
| `BAD_REQUEST` | Message mal formé ou champ manquant | Requête invalide |
| `UNKNOWN_TYPE` | Type de message inconnu | Action non reconnue |
| `AUTH_INVALID` | Identifiants incorrects | Identifiants incorrects |
| `AUTH_REQUIRED` | Action réservée à un utilisateur connecté | Vous devez vous connecter |
| `CONFLICT` | Ressource déjà existante | Cet élément existe déjà |
| `NOT_FOUND` | Ressource inexistante | Élément introuvable |
| `FRAME_TOO_LARGE` | Message au-delà de 1 Mo | Message trop volumineux |
| `INTERNAL` | Erreur interne du serveur | Erreur serveur, réessayez plus tard |

**Règle :** l'application affiche le message utilisateur, jamais le code brut.

---

## 8. Sécurité

- Aucun mot de passe n'est renvoyé dans une réponse.
- Un échec de connexion renvoie toujours `AUTH_INVALID`, sans révéler si le login existe.
- Le jeton de session est généré par le serveur et ne contient aucune donnée sensible.
- TCP ne chiffre pas les échanges. Le prototype fonctionne sur réseau local isolé. TLS est l'étape suivante avant toute mise en production.

---

## 9. Validation

| Élément | Olama | Abdourahim | Habiba |
|---|---|---|---|
| Framing `LF`, limite 1 Mo | ☑ | ☑ | ☐ |
| Structure requête et réponse | ☑ | ☑ | ☐ |
| Délai de 15 secondes | ☑ | ☑ | ☐ |
| Notifications (format réservé) | ☑ | ☑ | ☐ |
| Types et codes d'erreur | ☑ | ☑ | ☐ |
| Code pour requête sans `id` | ☐ | ☐ | ☐ |

**Date de validation :** 6 novembre 2026 (atelier)
**Mis à jour par :** Olama

---

## 10. Historique

| Date | Modification |
|---|---|
| 6 nov. 2026 | Décisions de l'atelier, accord d'Abdourahim |

---

## 11. Évolutions proposées (hors v1)

Le plan de travail du chef d'équipe décrit une enveloppe plus riche (champ `v`, `type` de type `request`/`response`/`event`, `action` séparé, jeton dans chaque requête). Elle n'est **pas** retenue en v1 : elle n'a pas été validée par l'équipe. Elle pourra faire l'objet d'une version 2 après décision du chef d'équipe.