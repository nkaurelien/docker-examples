# Wazuh - SIEM/XDR Open Source

Wazuh est une plateforme de sécurité unifiée offrant SIEM, XDR, détection d'intrusion et conformité.

## Fonctionnalités

| Catégorie | Description |
|-----------|-------------|
| **SIEM** | Collecte et analyse des logs |
| **XDR** | Détection et réponse aux menaces |
| **HIDS** | Détection d'intrusion hôte |
| **FIM** | Intégrité des fichiers |
| **Vulnerability** | Détection CVE |
| **Compliance** | PCI-DSS, GDPR, HIPAA |

## Architecture

| Composant | Port | Description |
|-----------|------|-------------|
| `wazuh-indexer` | 9200 | Stockage (OpenSearch) |
| `wazuh-manager` | 1514, 55000 | Analyse et API |
| `wazuh-dashboard` | 443 | Interface web |

## Prérequis

```bash
# Configurer vm.max_map_count (requis)
sudo sysctl -w vm.max_map_count=262144
```

## Démarrage Rapide

```bash
cd 11-security-identity/wazuh/

# 1. Générer les certificats SSL
./generate-certs.sh

# 2. Configurer les mots de passe
cp .env.example .env

# 3. Démarrer
docker compose up -d
```

**Accès Dashboard** : https://localhost:5601
- User : `admin`
- Password : voir `.env`

## Installer un Agent

### Linux

```bash
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor > /etc/apt/keyrings/wazuh.gpg
echo "deb [signed-by=/etc/apt/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list
apt update && apt install wazuh-agent

WAZUH_MANAGER="wazuh.manager.ip" dpkg-reconfigure wazuh-agent
systemctl enable --now wazuh-agent
```

### Docker

```yaml
services:
  wazuh-agent:
    image: wazuh/wazuh-agent:4.9.0
    environment:
      - WAZUH_MANAGER=wazuh.manager.ip
    volumes:
      - /var/log:/var/log:ro
```

## API

```bash
# Token
TOKEN=$(curl -sk -u wazuh-wui:password \
  https://localhost:55000/security/user/authenticate | jq -r '.data.token')

# Lister agents
curl -sk -H "Authorization: Bearer $TOKEN" \
  https://localhost:55000/agents | jq
```

## Ressources Requises

| Ressource | Valeur |
|-----------|--------|
| RAM | **8 GB minimum** |
| CPU | 4 cores |
| Disque | 50 GB+ |

## Références

- [Documentation](https://documentation.wazuh.com/)
- [Docker Guide](https://documentation.wazuh.com/current/deployment-options/docker/)
- [GitHub](https://github.com/wazuh/wazuh)
