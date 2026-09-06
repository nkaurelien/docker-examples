# CrowdSec Security Engine - Clés et Secrets

Ce dossier contient les clés de sécurité pour le moteur de détection d'intrusions CrowdSec et le bouncer Traefik.

## 📄 Fichiers associés :
* `crowdsec-lapi-key` : Clé secrète d'API locale (LAPI) utilisée par le bouncer Traefik pour interroger CrowdSec et bloquer les IPs malveillantes en temps réel.
* `crowdsec-enroll-key` *(optionnel)* : Clé d'enregistrement vers la console cloud CrowdSec (`https://app.crowdsec.net`).

## 🚀 Utilisation dans Ansible :
Le rôle Ansible [`ansible/roles/crowdsec`](../ansible/roles/crowdsec) injecte la clé LAPI dans le bouncer Traefik :

```yaml
crowdsec_lapi_key: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/crowdsec-lapi-key') | trim }}"
```

## 🔄 Générer/Renouveler une nouvelle clé LAPI :
```bash
python3 -c "import secrets; print(secrets.token_hex(16))" > .secrets/crowdsec-lapi-key
```
