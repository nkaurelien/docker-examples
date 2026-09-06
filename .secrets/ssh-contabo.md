# Serveur Contabo - Identifiants SSH

Ce dossier contient les fichiers de secret pour la connexion SSH au serveur Contabo FR.

## 📄 Fichiers associés :
* `ssh-contabo-server-ip` : Adresse IP publique du serveur (`161.97.89.185`).
* `ssh-contabo-server-user-login` : Nom d'utilisateur SSH (`nkaurelien`).
* `ssh-contabo-server-password` : Mot de passe SSH de l'utilisateur.

## 🚀 Utilisation dans Ansible :
Les variables `ansible_host`, `ansible_user` et `ansible_password` lisent dynamiquement ces fichiers dans `ansible/group_vars/webservers_fr.yml` et `ansible/inventory.yml` :

```yaml
ansible_host: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/ssh-contabo-server-ip') | trim }}"
ansible_user: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/ssh-contabo-server-user-login') | trim }}"
ansible_password: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/ssh-contabo-server-password') | trim }}"
```

## 🔐 Connexion manuelle en ligne de commande :
```bash
ssh $(cat .secrets/ssh-contabo-server-user-login)@$(cat .secrets/ssh-contabo-server-ip)
```
