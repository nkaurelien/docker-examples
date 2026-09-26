# OpenLDAP + phpLDAPadmin

OpenLDAP est une implémentation open-source du protocole LDAP (Lightweight Directory Access Protocol). Il s'agit du serveur d'annuaire le plus populaire pour gérer de manière centralisée les identités, les utilisateurs, les groupes et leurs attributs.

L'image Docker que nous utilisons est `osixia/openldap` car c'est la référence communautaire. Elle est accompagnée de `phpLDAPadmin`, une interface graphique web pour visualiser et éditer le contenu de l'annuaire facilement.

## 📁 Emplacement
La configuration complète avec le conteneur d'initialisation se trouve dans :
`compose/11-security-identity/identity-providers/openldap`

## 🚀 Fonctionnalités
- Initialisation automatique avec un conteneur dédié (création OUs, utilisateurs, groupes).
- Interface web (phpLDAPadmin).
- Persistance des données.
- Support du TLS, de la réplication, et des politiques de mots de passe complexes en natif (géré par osixia).

## 🛠️ Utilisation

### 1. Démarrer la stack

La stack comprend OpenLDAP, phpLDAPadmin et un script d'initialisation sécurisé par **Docker Secrets** :

```bash
cd compose/11-security-identity/identity-providers/openldap

# Initialiser le fichier d'environnement et les secrets
cp .env.example .env
cp -r .secrets.example .secrets

# Démarrer la stack
docker compose up -d
```

### 2. Le conteneur d'initialisation (`init-ldap`)

Nous avons inclus un conteneur nommé `init-ldap`. 
Celui-ci attend que le serveur OpenLDAP soit prêt, puis injecte un script d'initialisation (`scripts/init.sh`) qui :
1. Crée les OUs (Unités Organisationnelles) : `ou=devops`, `ou=appdev`.
2. Crée les Utilisateurs : `nkaurelien`, `idriss`, `michel`.
3. Crée les Groupes : `appdev-team`, `devops-team`.
4. Assigne les utilisateurs aux groupes correspondants via l'attribut `memberOf`.
5. Modifie les ACL (Listes de Contrôle d'Accès) pour autoriser par exemple l'utilisateur `nkaurelien` à lire l'annuaire.

*Ce conteneur d'initialisation s'arrête de lui-même une fois sa tâche accomplie avec succès (`restart: "no"`).*

### 3. Interface Web phpLDAPadmin

Une fois le serveur démarré, vous pouvez accéder à l'interface d'administration :
- **URL** : `http://localhost:8088`

> ⚠️ **Important pour la connexion :** phpLDAPadmin requiert le **DN complet** (Distinguished Name) dans le champ **Login DN**, et non pas un simple identifiant/username.

#### Option A : Connexion Administrateur (Gestion complète)
- **Login DN** : `cn=admin,dc=kamitbrains,dc=local`
- **Mot de passe** : `password`

#### Option B : Connexion Utilisateur (ex: Aurelien)
- **Login DN** : `cn=aurelien,ou=devops,dc=kamitbrains,dc=local`
- **Mot de passe** : `Aurelien@123`
*(Note : dans les applications tierces comme Nextcloud ou Grafana qui utilisent l'attribut `uid`, l'identifiant à saisir sera `nkaurelien`).*

### 4. Requêtes CLI (Vérification)

Vous pouvez tester l'accès LDAP directement depuis le conteneur principal avec la commande suivante :

```bash
docker exec -it openldap ldapsearch -x -D "cn=aurelien,ou=devops,dc=kamitbrains,dc=local" -w Aurelien@123 -b "dc=kamitbrains,dc=local"
```
Cela vous confirmera que l'utilisateur `nkaurelien` (et son mot de passe) sont correctement configurés et ont l'accès en lecture.

---

## 🌳 Concepts et Objets LDAP Fondamentaux

L'annuaire LDAP organise les données sous forme d'un **arbre hiérarchique** (DIT : *Directory Information Tree*). Chaque entrée dans l'arbre est définie par son **DN** (*Distinguished Name*, son chemin absolu) et ses **`objectClass`** (qui définissent les attributs obligatoires et optionnels).

### 1. Structure de l'annuaire déployé

```text
dc=kamitbrains,dc=local (Racine / Domaine)
 │
 ├── cn=appdev-team        [Classe: groupOfNames]
 ├── cn=devops-team        [Classe: groupOfNames]
 │
 ├── ou=devops             [Classe: organizationalUnit]
 │    └── cn=aurelien      [Classe: inetOrgPerson] (uid: nkaurelien)
 │
 └── ou=appdev             [Classe: organizationalUnit]
      ├── cn=idriss        [Classe: inetOrgPerson] (uid: nnid)
      └── cn=michel        [Classe: inetOrgPerson] (uid: edmich)
```

### 2. Principaux types d'objets

| Type d'Objet | Classe principale | Description | Attributs usuels |
| :--- | :--- | :--- | :--- |
| **Racine / Domaine** | `dcObject`, `organization` | Le sommet de l'arbre, représentant le domaine. | `dc` (Domain Component), `o` (Organization) |
| **Unité d'organisation (OU)** | `organizationalUnit` | Dossier logique pour regrouper utilisateurs ou machines. | `ou` (Organizational Unit name) |
| **Utilisateur / Compte** | `inetOrgPerson` | Compte utilisateur standard pour l'authentification. | `cn`, `sn`, `givenName`, `mail`, `uid`, `userPassword` |
| **Groupe d'utilisateurs** | `groupOfNames` | Groupe statique contenant la liste des membres. | `cn`, `description`, `member` (DNs complets) |
| **Rôle** | `organizationalRole` | Poste ou fonction dans l'organisation. | `cn`, `roleOccupant` |

### 3. Relation Utilisateur / Groupe (`member` vs `memberOf`)

- **`member` (sur le groupe)** : Contient le DN de chaque personne membre (ex: `member: cn=aurelien,ou=devops,dc=kamitbrains,dc=local`).
- **`memberOf` (sur l'utilisateur)** : Attribut miroir placé directement sur la fiche utilisateur pour simplifier les requêtes de droits d'accès depuis les applications clientes (Nextcloud, Keycloak, Grafana, Portainer).

---

## 🔒 Sécurité et Durcissement

### 1. Hachage des Mots de Passe (`{SSHA}`)
Les mots de passe ne sont **jamais stockés en clair**. Le conteneur d'initialisation utilise l'outil officiel OpenLDAP `slappasswd` pour générer un hachage salé au format `{SSHA}` (SHA-1 + Salt aléatoire) lors de la création de chaque compte :

```bash
# Exemple de génération d'un mot de passe sécurisé :
slappasswd -s "MonMotDePasseSecret"
# Résultat : {SSHA}hSJamTTdc8MudXG9O2Bw5pq6uifvPrdC
```
Dans l'annuaire, l'attribut `userPassword` contient uniquement cette empreinte. Lors de l'authentification (via phpLDAPadmin ou une application cliente), OpenLDAP compare le sel et le hash sans jamais avoir besoin de connaître le mot de passe en clair.

### 2. Ségrégation des Privilèges d'Administration (Double Secret)
Deux comptes administrateurs distincts sont configurés avec des mots de passe séparés via **Docker Secrets** :
- **`ldap_admin_password`** (`cn=admin,dc=kamitbrains,dc=local`) : Administrateur du DIT (données de l'annuaire : utilisateurs, groupes, OUs).
- **`ldap_config_password`** (`cn=admin,cn=config`) : Administrateur système du moteur OpenLDAP (schémas, overlays, ACLs, modules).

Cette séparation empêche qu'un compte ayant des droits sur les données puisse compromettre ou altérer le moteur OpenLDAP sous-jacent.

### 3. Overlay Password Policy (`ppolicy`) & Protection Anti-Bruteforce
L'overlay OpenLDAP **`ppolicy`** est activé automatiquement sur la base de données `mdb`. Une politique globale par défaut est appliquée sous `cn=default,ou=policies,dc=kamitbrains,dc=local` :
- **Longueur minimale (`pwdMinLength`)** : 8 caractères obligatoires.
- **Verrouillage de compte (`pwdLockout`)** : Activé (`TRUE`).
- **Tolérance aux échecs (`pwdMaxFailure`)** : 5 tentatives infructueuses autorisées.
- **Durée de verrouillage (`pwdLockoutDuration`)** : 15 minutes (900 secondes) de blocage automatique du compte en cas de dépassement.
- **Fenêtre de comptage des échecs (`pwdFailureCountInterval`)** : 15 minutes.
- **Hachage automatique des modifications (`olcPPolicyHashCleartext`)** : Tout mot de passe modifié via LDAP en clair est automatiquement haché avant stockage.

### 4. Bonnes Pratiques en Production
- **Chiffrement réseau (TLS/LDAPS) :** En production, privilégiez le port sécurisé `636` (LDAPS) ou `StartTLS` sur le port `389` pour éviter l'interception des requêtes sur le réseau local.
- **phpLDAPadmin via Reverse Proxy HTTPS :** Si l'interface web doit être exposée en dehors du réseau local, placez-la impérativement derrière un Reverse Proxy avec certificat SSL valide (Traefik ou Nginx Proxy Manager).
- **Modification des secrets :** Les fichiers du dossier `.secrets/` doivent impérativement être modifiés avec des mots de passe uniques et forts avant tout déploiement en production.
