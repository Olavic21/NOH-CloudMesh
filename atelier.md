# Atelier protocole — N.O.H. CloudMesh

**Tâche :** P-05 · **Domaine :** `common/` (relecture obligatoire des trois membres, règle R5)
**Participants :** Olama (Vick), Abdourahim (Frontend Flutter), Habiba (Infrastructure et base de données)
**Date de l'atelier :** lundi 9 novembre 2026
**Durée prévue :** 60 minutes
**Document à mettre à jour :** `docs/protocole.md`

> Statut : **brouillon de travail.** Aucune décision n'est définitive tant qu'elle n'est pas notée dans la section 8 par les trois membres.

---

## 1. Objectif de l'atelier

Définir ensemble le format des messages échangés entre l'application Flutter et le serveur Dart, afin que le client et le serveur puissent développer leur partie en parallèle sans se bloquer.

**Résultat attendu :** les cinq décisions de la section 3 sont tranchées, la liste des types de messages de la semaine 3 est établie, et les codes d'erreur de base sont validés.

---

## 2. Contexte technique

- Le client et le serveur communiquent par **TCP**.
- TCP transporte un **flux d'octets** : il ne garantit pas qu'un message arrive d'un seul bloc. Le protocole doit donc dire où commence et où finit chaque message.
- Les messages sont au format **JSON**.
- Le serveur doit pouvoir gérer **plusieurs clients simultanément**.

---

## 3. Les cinq décisions à prendre

Pour chaque décision : la proposition est déjà écrite, il faut la valider, la modifier ou la remplacer. Notez le résultat dans la colonne *Décision finale*.

### Décision 1 : délimitation des trames

**Proposition :** chaque message est précédé d'un préfixe de longueur sur 4 octets (entier non signé, big-endian), suivi de exactement autant d'octets de JSON.

| Option | Avantage | Inconvénient |
|---|---|---|
| A. Préfixe de longueur 4 octets (proposition) | Simple, robuste, indépendant du contenu | Il faut lire les octets avec précision |
| B. Délimiteur de fin (par exemple saut de ligne) | Lisible à la main avec Netcat | Interdit les sauts de ligne dans le JSON, fragile |

**Décision finale :** On va aller avec l'option B

### Décision 2 : taille maximale d'une trame

**Proposition :** 64 Ko (65 536 octets). Une trame plus grande est rejetée, et la connexion est fermée.

**Question à Abdourahim :** a-t-il besoin de transmettre des données plus volumineuses, comme des images ? Si oui, cette limite doit être revue.

**Décision finale :** On va partir sur la base de 1 Mo max 

### Décision 3 : encodage et racine du message

**Proposition :** UTF-8 uniquement. La racine de chaque message est un **objet** JSON, jamais un tableau ni une valeur simple.

**Décision finale :** Oui UTF-8 sera considéré comme système d'encodage

### Décision 4 : structure d'une requête

**Proposition :**

```json
{
  "id": 42,
  "type": "auth.login",
  "payload": { "login": "...", "password": "..." }
}
```

| Champ | Type | Obligatoire | Rôle |
|---|---|---|---|
| `id` | entier | oui | Relie la réponse à la requête |
| `type` | chaîne | oui | Action demandée |
| `payload` | objet | non | Données propres à l'action |

**Questions à trancher :**
- Le `id` est-il unique par connexion, ou par utilisateur ? *(Proposition : par connexion.)*
- Faut-il une convention de nommage pour les types, comme `domaine.action` ? *(Proposition : oui.)*

**Décision finale :** Le id sera unique par connexion et oui une convention de nommage est préférable

### Décision 5 : structure d'une réponse

**Proposition :**

Succès :
```json
{ "id": 42, "ok": true, "payload": { "token": "..." } }
```

Échec :
```json
{ "id": 42, "ok": false, "error": { "code": "AUTH_INVALID", "message": "Identifiants incorrects" } }
```

**Règle de sécurité :** le champ `message` est destiné à l'utilisateur. Il ne contient jamais de détail interne (requête SQL, nom de table, trace d'exception).

**Décision finale :** Exactement

---

## 4. Questions de comportement

À trancher pendant l'atelier.

| # | Question | Proposition | Décision finale |
|---|---|---|---|
| Q1 | Requête sans `id` : que répond le serveur ? | Réponse d'erreur `BAD_REQUEST`, sans `id` | code 501 (identifiant absent) |
| Q2 | JSON invalide : fermer la connexion ou seulement rejeter la requête ? | Rejeter la requête, garder la connexion | rejeter la requête, garder la connexion|
| Q3 | Délai d'attente d'une réponse côté client | 10 secondes, à confirmer avec Abdourahim | On va aller avec 15 secondes |
| Q4 | Plusieurs requêtes envoyées sans attendre les réponses ? | Autorisé : la corrélation se fait par `id` | Okay, la corrélation va se faire par id |
| Q5 | Le serveur envoie-t-il des messages sans requête (notifications) ? | Non pour le prototype | Okay mais il faudra ajouter cette fonctionnalité pour faciliter les mises à jour |

---

## 5. Types de messages nécessaires

Liste de départ, à compléter par Abdourahim selon les écrans de l'application.

| Type | Sens | Description | Semaine |
|---|---|---|---|
| `auth.register` | Client → serveur | Création d'un compte | S3 |
| `auth.login` | Client → serveur | Connexion | S3 |
| `auth.logout` | Client → serveur | Déconnexion | S3 |
| `echo` | Client → serveur | Test de connexion (réponse identique) | S1 |
| ______________ | ______________ | ______________________________________ | ______ |
| ______________ | ______________ | ______________________________________ | ______ |

**Important :** les fonctionnalités métier au-delà de l'authentification ne sont pas définies dans les guides. Cette section doit être complétée avec les besoins réels de l'équipe.

---

## 6. Codes d'erreur

Liste de départ, à valider.

| Code | Signification | Message affiché à l'utilisateur |
|---|---|---|
| `BAD_REQUEST` | Message mal formé ou champ manquant | Requête invalide |
| `UNKNOWN_TYPE` | Type de message inconnu | Action non reconnue |
| `AUTH_INVALID` | Identifiants incorrects | Identifiants incorrects |
| `AUTH_REQUIRED` | Action réservée à un utilisateur connecté | Vous devez vous connecter |
| `FRAME_TOO_LARGE` | Trame au-delà de la taille maximale | Message trop volumineux |
| `INTERNAL` | Erreur interne du serveur | Erreur serveur, réessayez plus tard |
| ______________ | ______________________________________ | ________________________________ |

**Règle :** l'application Flutter affiche le message utilisateur, jamais le code brut. Le code sert au débogage et aux tests.

---

## 7. Points de sécurité à confirmer

- [ ] Aucun mot de passe n'est renvoyé dans une réponse.
- [ ] Les messages d'erreur ne révèlent pas si un login existe (« identifiants incorrects » dans tous les cas).
- [ ] Le jeton de session est généré par le serveur et ne contient aucune donnée sensible.
- [ ] TCP ne chiffre pas les échanges. Le prototype fonctionne sur réseau local isolé. TLS est documenté comme étape suivante.

---

## 8. Résultats de l'atelier

À remplir pendant la réunion. **Chaque ligne doit être validée par les trois membres.**

| Élément | Décision retenue | Validé par (initiales) |
|---|---|---|
| Décision 1 : délimitation | | |
| Décision 2 : taille maximale | | |
| Décision 3 : encodage | | |
| Décision 4 : requête | | |
| Décision 5 : réponse | | |
| Q1 à Q5 | | |
| Types de messages (section 5) | | |
| Codes d'erreur (section 6) | | |

**Date de validation :** 06/11/2026

**Personne chargée de mettre à jour `docs/protocole.md` :** Abdosrad07

---

## 9. Actions après l'atelier

| Action | Responsable | Échéance |
|---|---|---|
| Mettre à jour `docs/protocole.md` avec les décisions retenues | Olama | Mardi 10 nov. |
| Ouvrir la PR `[P-05] Protocole JSON v1` vers `dev` | Olama | Mardi 10 nov. |
| Relecture de la PR par les trois membres | Abdourahim, Habiba | Mercredi 11 nov. |
| Vérifier que les types de messages correspondent aux écrans Flutter | Abdourahim | Mercredi 11 nov. |
| Vérifier que le schéma PostgreSQL correspond aux données échangées | Habiba | Jeudi 12 nov. |

---

## 10. Ce que la PR doit contenir

Pour la PR `[P-05] Protocole JSON v1` :

- **Tâche :** P-05, atelier protocole.
- **Modifications :** `docs/protocole.md` et ce fichier d'atelier, une fois validé.
- **Tests effectués :** aucun test de code à ce stade, la PR est documentaire.
- **Critère d'acceptation :** le protocole est validé par les trois membres, et chaque décision de la section 8 est renseignée.
- **Points à relire :** section 3, décision 2 (taille maximale), section 5 (types de messages).