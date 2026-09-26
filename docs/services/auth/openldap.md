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

La stack comprend OpenLDAP, phpLDAPadmin et un script d'initialisation (qui s'assure d'importer vos utilisateurs par défaut au démarrage) :

```bash
cd compose/11-security-identity/identity-providers/openldap
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
