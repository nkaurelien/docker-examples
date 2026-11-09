# Serveur VPS - Identifiants SSH (exemple)

Fiche d'exemple décrivant les fichiers de secret attendus pour la connexion SSH à un serveur VPS public.
Aucune valeur réelle n'est versionnée : les fichiers ci-dessous sont gitignorés.

## 📄 Fichiers associés :
* `ssh-vps-server-ip` : Adresse IP publique du serveur (ex. `203.0.113.10`, plage de documentation RFC 5737).
* `ssh-vps-server-user-login` : Nom d'utilisateur SSH (ex. `deploy`).
* `ssh-vps-server-password` : Mot de passe SSH de l'utilisateur.

## 🚀 Utilisation dans Ansible :
L'inventaire d'exemple `ansible/inventory.yml` déclare l'hôte `vps_server` (IP et utilisateur neutres) et lit le mot de passe depuis `.secrets/` :

```yaml
ansible_host: 203.0.113.10
ansible_user: deploy
ansible_password: "{{ lookup('file', playbook_dir ~ '/../.secrets/ssh-vps-server-password') | trim }}"
```

Pour tout lire depuis `.secrets/`, remplacez `ansible_host` / `ansible_user` par :

```yaml
ansible_host: "{{ lookup('file', playbook_dir ~ '/../.secrets/ssh-vps-server-ip') | trim }}"
ansible_user: "{{ lookup('file', playbook_dir ~ '/../.secrets/ssh-vps-server-user-login') | trim }}"
```

## 🔐 Connexion manuelle en ligne de commande :
```bash
ssh $(cat .secrets/ssh-vps-server-user-login)@$(cat .secrets/ssh-vps-server-ip)
```
