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
- Mots de passe gérés par Docker Secrets et hachés en `{SSHA}`.
- Politique de mots de passe (`ppolicy`) : longueur minimale et verrouillage anti-bruteforce.
- `memberOf` maintenu automatiquement par l'overlay `memberof`.
- Script d'initialisation idempotent (relançable sans erreur).

## 🛠️ Utilisation

### 1. Démarrer la stack

La stack comprend OpenLDAP, phpLDAPadmin et un script d'initialisation sécurisé par **Docker Secrets** :

```bash
cd compose/11-security-identity/identity-providers/openldap

# Initialiser le fichier d'environnement et les secrets
cp .env.example .env
cp -r .secrets.example .secrets

# Créer le réseau Traefik (une seule fois, si Traefik ne tourne pas déjà)
docker network create traefik-public

# Démarrer la stack
docker compose up -d
```

### 2. Le conteneur d'initialisation (`init-ldap`)

Nous avons inclus un conteneur nommé `init-ldap`. 
Celui-ci attend que le serveur OpenLDAP soit prêt, puis injecte un script d'initialisation (`scripts/init.sh`) qui :
1. Crée les OUs (Unités Organisationnelles) : `ou=devops`, `ou=appdev`.
2. Crée les utilisateurs `cn=aurelien` (uid `nkaurelien`), `cn=idriss` (uid `nnid`) et `cn=michel` (uid `edmich`), avec des mots de passe hachés en `{SSHA}`.
3. Reconfigure l'overlay `memberof` pour suivre `groupOfNames`/`member` (osixia le configure par défaut pour `groupOfUniqueNames`/`uniqueMember`).
4. Crée les groupes `appdev-team` (aurelien, idriss) et `devops-team` (aurelien, michel). L'overlay renseigne automatiquement `memberOf` sur chaque utilisateur.
5. Modifie les ACL (Listes de Contrôle d'Accès) pour autoriser `cn=aurelien` à lire l'annuaire.
6. Active l'overlay `ppolicy` et crée la politique par défaut `cn=default,ou=policies`.

*Ce conteneur s'arrête une fois sa tâche terminée (`restart: "no"`). Il sort en erreur (code 1) si un secret est absent ou vide, ou si une opération LDAP échoue réellement.*

Le script est **idempotent** : les résultats « existe déjà » (codes LDAP 68 et 20) sont considérés comme des succès, et l'overlay `ppolicy` n'est ajouté que s'il est absent. Pour le relancer :

```bash
docker compose up -d --force-recreate init-ldap
docker logs init-ldap
```

### 3. Interface Web phpLDAPadmin

Une fois le serveur démarré, vous pouvez accéder à l'interface d'administration. Les mots de passe ci-dessous sont les valeurs par défaut de `.secrets.example/` ; ce sont les fichiers de `.secrets/` qui font foi.
- **Accès direct (HTTP local)** : `http://localhost:8088`
- **Accès via Traefik (HTTPS / TLS)** : `https://ldap.kamitbrains.local` (ou le nom d'hôte configuré dans `PHPLDAPADMIN_HOSTNAME`)

> ⚠️ **Important pour la connexion :** phpLDAPadmin requiert le **DN complet** (Distinguished Name) dans le champ **Login DN**, et non pas un simple identifiant/username.

![Page de connexion phpLDAPadmin](https://raw.githubusercontent.com/nkaurelien/docker-examples/main/compose/11-security-identity/identity-providers/openldap/screenshots/phpldapadmin-login.png)

#### Option A : Connexion Administrateur (Gestion complète)
- **Login DN** : `cn=admin,dc=kamitbrains,dc=local`
- **Mot de passe** : `password` (`.secrets/ldap_admin_password.txt`)

#### Option B : Connexion Utilisateur (ex: Aurelien)
- **Login DN** : `cn=aurelien,ou=devops,dc=kamitbrains,dc=local`
- **Mot de passe** : `Aurelien@123` (`.secrets/user_aurelien_password.txt`)
*(Note : dans les applications tierces comme Nextcloud ou Grafana qui utilisent l'attribut `uid`, l'identifiant à saisir sera `nkaurelien`).*

Une fois connecté en admin, l'arbre de l'annuaire affiche les groupes, les OUs et le conteneur de politiques de mots de passe créés par `init-ldap` :

![Arbre de l'annuaire dans phpLDAPadmin après initialisation](https://raw.githubusercontent.com/nkaurelien/docker-examples/main/compose/11-security-identity/identity-providers/openldap/screenshots/phpldapadmin-tree.png)

### 4. Requêtes CLI (Vérification)

Vous pouvez tester l'accès LDAP directement depuis le conteneur principal avec la commande suivante :

```bash
docker exec -it openldap ldapsearch -x -D "cn=aurelien,ou=devops,dc=kamitbrains,dc=local" -w Aurelien@123 -b "dc=kamitbrains,dc=local"
```
Cela vous confirmera que l'utilisateur `cn=aurelien` (uid `nkaurelien`) et son mot de passe sont correctement configurés et qu'il a l'accès en lecture.

Pour vérifier les appartenances aux groupes calculées par l'overlay :

```bash
docker exec openldap ldapsearch -x -LLL -D "cn=admin,dc=kamitbrains,dc=local" -w password \
  -b "dc=kamitbrains,dc=local" "(objectClass=inetOrgPerson)" memberOf
```

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

!!! warning "Ne jamais écrire `memberOf` à la main"
    `memberOf` doit être calculé par l'overlay `memberof` à partir des `member` des groupes. L'écrire à la main crée des incohérences : ajouts et retraits de membres ne sont plus répercutés. Point d'attention avec `osixia/openldap` : l'overlay suit par défaut `groupOfUniqueNames`/`uniqueMember`. Avec des `groupOfNames`, il faut changer `olcMemberOfGroupOC` et `olcMemberOfMemberAD` **avant** de créer les groupes, ce que fait le script d'initialisation.

---

## 🔒 Sécurité et Durcissement

### 1. Hachage des Mots de Passe (`{SSHA}`)
Les mots de passe ne sont **jamais stockés en clair**. Le conteneur d'initialisation utilise l'outil officiel OpenLDAP `slappasswd` pour générer un hachage salé au format `{SSHA}` (SHA-1 + sel aléatoire) lors de la création de chaque compte. `{SSHA}` reste un hachage rapide, suffisant pour un lab ; en production, préférez un hachage lent comme Argon2 (module `pw-argon2`).

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
- **Contrôle qualité (`pwdCheckQuality: 1`)** : indispensable, sans lui `pwdMinLength` est ignoré.
- **Longueur minimale (`pwdMinLength`)** : 8 caractères obligatoires.
- **Verrouillage de compte (`pwdLockout`)** : Activé (`TRUE`).
- **Tolérance aux échecs (`pwdMaxFailure`)** : 5 tentatives infructueuses autorisées.
- **Durée de verrouillage (`pwdLockoutDuration`)** : 15 minutes (900 secondes) de blocage automatique du compte en cas de dépassement.
- **Fenêtre de comptage des échecs (`pwdFailureCountInterval`)** : 15 minutes.
- **Hachage automatique des modifications (`olcPPolicyHashCleartext`)** : Tout mot de passe modifié via LDAP en clair est automatiquement haché avant stockage.

La politique ne s'applique pas au root DN (`cn=admin,...`), qui contourne ppolicy. Test rapide (doit échouer avec `Constraint violation`) :

```bash
docker exec openldap ldappasswd -x -D "cn=michel,ou=appdev,dc=kamitbrains,dc=local" -w Michel@123 -s abc
```

### 4. Bonnes Pratiques en Production
- **Chiffrement réseau (TLS/LDAPS) :** En production, privilégiez le port sécurisé `636` (LDAPS) ou `StartTLS` sur le port `389` pour éviter l'interception des requêtes sur le réseau local.
- **phpLDAPadmin via Reverse Proxy HTTPS :** Si l'interface web doit être exposée en dehors du réseau local, placez-la impérativement derrière un Reverse Proxy avec certificat SSL valide (Traefik ou Nginx Proxy Manager).
- **Certificats Traefik :** Let's Encrypt ne délivre pas de certificat pour un nom en `.local`. Utilisez un vrai domaine (challenge DNS pour un hôte interne) ou acceptez le certificat auto-signé par défaut de Traefik en lab.
- **Label `traefik.docker.network` :** phpLDAPadmin est sur deux réseaux ; ce label force Traefik à passer par `traefik-public`, sinon il peut viser l'IP de `ldap-network` et renvoyer une 502.
- **Modification des secrets :** Les fichiers du dossier `.secrets/` doivent impérativement être modifiés avec des mots de passe uniques et forts avant tout déploiement en production.

---

## 🔗 Références & Liens Utiles
- [Dépôt GitHub osixia/container-openldap](https://github.com/osixia/container-openldap)
- [Guide Medium : Setting up OpenLDAP server with Docker (par Amrutha)](https://medium.com/@amrutha_20595/setting-up-openldap-server-with-docker-d38781c259b2)
