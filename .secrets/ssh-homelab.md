# Serveur Homelab - Identifiants SSH & FQDN (exemple)

Fiche d'exemple décrivant les fichiers de secret attendus pour la connexion SSH et la configuration réseau d'un serveur homelab.
Aucune valeur réelle n'est versionnée : les fichiers ci-dessous sont gitignorés.

## 📄 Fichiers associés :
* `ssh-homelab-fqdn` : Nom de domaine pleinement qualifié / FQDN (ex. `example.local`).
* `ssh-homelab-ip` : Adresse IP locale du serveur (ex. `192.168.1.10`).
* `ssh-homelab-user-login` : Nom d'utilisateur SSH (ex. `deploy`).
* `ssh-homelab-password` : Mot de passe SSH de l'utilisateur.

## 🌐 Déploiement des sous-domaines :
Le domaine racine (ex. `example.local`) sert de cible pour les sous-domaines de l'homelab (ex. `*.example.local`, `traefik.example.local`, `portainer.example.local`, etc.).

## 🚀 Utilisation dans Ansible :
L'inventaire d'exemple `ansible/inventory.yml` et `ansible/group_vars/homelab.yml` déclarent l'hôte `homelab_server` avec des valeurs neutres et lisent le mot de passe depuis `.secrets/` :

```yaml
ansible_host: 192.168.1.10
ansible_fqdn: example.local
ansible_user: deploy
ansible_password: "{{ lookup('file', playbook_dir ~ '/../.secrets/ssh-homelab-password') | trim }}"
```

Pour tout lire depuis `.secrets/` :

```yaml
ansible_host: "{{ lookup('file', playbook_dir ~ '/../.secrets/ssh-homelab-ip') | trim }}"
ansible_user: "{{ lookup('file', playbook_dir ~ '/../.secrets/ssh-homelab-user-login') | trim }}"
ansible_fqdn: "{{ lookup('file', playbook_dir ~ '/../.secrets/ssh-homelab-fqdn') | trim }}"
```

## 🔐 Connexion manuelle en ligne de commande :
```bash
ssh $(cat .secrets/ssh-homelab-user-login)@$(cat .secrets/ssh-homelab-fqdn)
```
