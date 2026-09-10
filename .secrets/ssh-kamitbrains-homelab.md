# Serveur KamitBrains Homelab - Identifiants SSH & FQDN

Ce dossier contient les fichiers de secret pour la connexion SSH et la configuration réseau du serveur KamitBrains Homelab.

## 📄 Fichiers associés :
* `ssh-kamitbrains-homelab-fqdn` : Nom de domaine pleinement qualifié / FQDN (`kamitbrains.local`).
* `ssh-kamitbrains-homelab-ip` : Adresse IP locale du serveur (`192.168.0.210`).
* `ssh-kamitbrains-homelab-mac` : Adresse MAC de l'interface réseau (`68-1D-EF-64-8E-85`).
* `ssh-kamitbrains-homelab-user-login` : Nom d'utilisateur SSH (`kamitbrains`).
* `ssh-kamitbrains-homelab-password` : Mot de passe SSH de l'utilisateur (`kamit`).

## 🌐 Déploiement des sous-domaines :
Le domaine racine `kamitbrains.local` (IP `192.168.0.210`) sert de cible pour le déploiement des sous-domaines de l'homelab (ex: `*.kamitbrains.local`, `traefik.kamitbrains.local`, `portainer.kamitbrains.local`, etc.).

## 🚀 Utilisation dans Ansible :
Les variables d'inventaire lisent dynamiquement ces fichiers dans `ansible/inventory.yml` :

```yaml
ansible_host: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/ssh-kamitbrains-homelab-ip') | trim }}"
ansible_user: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/ssh-kamitbrains-homelab-user-login') | trim }}"
ansible_password: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/ssh-kamitbrains-homelab-password') | trim }}"
ansible_fqdn: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/ssh-kamitbrains-homelab-fqdn') | trim }}"
```

## 🔐 Connexion manuelle en ligne de commande :
```bash
ssh kamitbrains-homelab
# ou
ssh kamitbrains.local
# ou
ssh $(cat .secrets/ssh-kamitbrains-homelab-user-login)@$(cat .secrets/ssh-kamitbrains-homelab-fqdn)
```
