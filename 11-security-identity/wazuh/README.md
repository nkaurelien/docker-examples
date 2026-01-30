# Wazuh - Open Source SIEM/XDR Platform

Plateforme de sécurité unifiée : SIEM, XDR, détection d'intrusion, conformité.

## Fonctionnalités

| Catégorie | Description |
|-----------|-------------|
| **SIEM** | Collecte et analyse des logs de sécurité |
| **XDR** | Détection et réponse étendues aux menaces |
| **HIDS** | Détection d'intrusion sur les hôtes |
| **FIM** | Surveillance d'intégrité des fichiers |
| **Vulnerability** | Détection des vulnérabilités CVE |
| **SCA** | Security Configuration Assessment |
| **Compliance** | PCI-DSS, GDPR, HIPAA, NIST 800-53 |
| **Cloud** | AWS, Azure, GCP, containers |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Wazuh Stack                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐ │
│  │  Wazuh Indexer  │    │  Wazuh Manager  │    │  Dashboard  │ │
│  │  (OpenSearch)   │◄───│   (Analysis)    │    │   (Web UI)  │ │
│  │     :9200       │    │  :1514 :55000   │    │   :5601     │ │
│  └────────┬────────┘    └────────┬────────┘    └──────┬──────┘ │
│           │                      │                     │        │
│           └──────────────────────┼─────────────────────┘        │
│                                  │                              │
│                         ┌────────▼────────┐                     │
│                         │  Wazuh Agents   │                     │
│                         │   (Endpoints)   │                     │
│                         └─────────────────┘                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Prérequis

- **RAM** : 8GB minimum (16GB recommandé)
- **CPU** : 4 cores minimum
- **Disque** : 50GB+ (selon rétention logs)
- **sysctl** : `vm.max_map_count=262144`

```bash
# Configurer vm.max_map_count (requis pour OpenSearch)
sudo sysctl -w vm.max_map_count=262144

# Persister le changement
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

## Démarrage Rapide

### 1. Générer les certificats SSL

```bash
cd 11-security-identity/wazuh/

# Générer les certificats avec l'outil Wazuh
./generate-certs.sh
```

### 2. Configurer les mots de passe

```bash
cp .env.example .env
# Éditer .env et changer les mots de passe par défaut
```

### 3. Démarrer Wazuh

```bash
docker compose up -d
```

### 4. Accéder au Dashboard

- URL : https://localhost:5601 ou https://wazuh.apps.local
- User : `admin`
- Password : Valeur de `INDEXER_PASSWORD` dans `.env`

## Ports

| Port | Protocole | Service | Description |
|------|-----------|---------|-------------|
| 5601 | TCP | Dashboard | Interface web |
| 1514 | TCP | Manager | Connexion agents |
| 1515 | TCP | Manager | Enrollment agents |
| 514 | UDP | Manager | Syslog |
| 55000 | TCP | Manager | API Wazuh |
| 9200 | TCP | Indexer | API OpenSearch (interne) |

## Installation d'un Agent

### Linux (Debian/Ubuntu)

```bash
# Télécharger et installer
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor > /etc/apt/keyrings/wazuh.gpg
echo "deb [signed-by=/etc/apt/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list
apt update && apt install wazuh-agent

# Configurer
WAZUH_MANAGER="wazuh.manager.ip" WAZUH_AGENT_NAME="myserver" \
  dpkg-reconfigure wazuh-agent

# Démarrer
systemctl daemon-reload
systemctl enable --now wazuh-agent
```

### Docker (Conteneur agent)

```yaml
services:
  wazuh-agent:
    image: wazuh/wazuh-agent:4.9.0
    hostname: docker-host
    restart: unless-stopped
    environment:
      - WAZUH_MANAGER=wazuh.manager.ip
      - WAZUH_AGENT_GROUP=default
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /var/log:/var/log:ro
```

### Windows

```powershell
# PowerShell (Admin)
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.9.0-1.msi -OutFile wazuh-agent.msi
msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER="wazuh.manager.ip" WAZUH_AGENT_NAME="windows-pc"

# Démarrer le service
NET START WazuhSvc
```

## Configuration

### Activer la détection de vulnérabilités

Déjà activé dans `wazuh_manager.conf` :

```xml
<vulnerability-detection>
  <enabled>yes</enabled>
  <index-status>yes</index-status>
  <feed-update-interval>60m</feed-update-interval>
</vulnerability-detection>
```

### Surveillance d'intégrité des fichiers (FIM)

```xml
<syscheck>
  <directories>/etc,/usr/bin,/usr/sbin</directories>
  <directories>/var/www</directories>
  <directories realtime="yes">/home</directories>
</syscheck>
```

### Intégration Slack

```xml
<integration>
  <name>slack</name>
  <hook_url>https://hooks.slack.com/services/XXX/YYY/ZZZ</hook_url>
  <level>10</level>
  <alert_format>json</alert_format>
</integration>
```

### Règles personnalisées

Créer `/var/ossec/etc/rules/local_rules.xml` :

```xml
<group name="custom,">
  <rule id="100001" level="10">
    <if_sid>5710</if_sid>
    <match>Failed password for root</match>
    <description>Failed SSH login for root user</description>
  </rule>
</group>
```

## API Wazuh

```bash
# Authentification
TOKEN=$(curl -s -k -u wazuh-wui:MyS3cr37P450r.*- \
  https://localhost:55000/security/user/authenticate | jq -r '.data.token')

# Lister les agents
curl -s -k -H "Authorization: Bearer $TOKEN" \
  https://localhost:55000/agents | jq

# Statut du manager
curl -s -k -H "Authorization: Bearer $TOKEN" \
  https://localhost:55000/manager/status | jq

# Vulnérabilités d'un agent
curl -s -k -H "Authorization: Bearer $TOKEN" \
  https://localhost:55000/vulnerability/001 | jq
```

## Commandes Utiles

```bash
# Logs manager
docker logs -f wazuh-manager

# Logs indexer
docker logs -f wazuh-indexer

# Statut des services
docker exec wazuh-manager /var/ossec/bin/wazuh-control status

# Liste des agents connectés
docker exec wazuh-manager /var/ossec/bin/agent_control -l

# Redémarrer un agent
docker exec wazuh-manager /var/ossec/bin/agent_control -R 001

# Forcer scan vulnérabilités
docker exec wazuh-manager /var/ossec/bin/wazuh-control restart
```

## Intégrations

### Avec Docker/Containers

Wazuh peut monitorer les conteneurs Docker :

```xml
<!-- Dans ossec.conf -->
<wodle name="docker-listener">
  <disabled>no</disabled>
</wodle>
```

### Avec Cloud (AWS, Azure, GCP)

```xml
<!-- AWS CloudTrail -->
<wodle name="aws-s3">
  <disabled>no</disabled>
  <bucket type="cloudtrail">
    <name>my-cloudtrail-bucket</name>
    <aws_profile>default</aws_profile>
  </bucket>
</wodle>
```

### Avec ClamAV

Intégration pour scanner les fichiers détectés :

```xml
<integration>
  <name>custom-clamav</name>
  <hook_url>http://clamav:8080/api/v1/scan</hook_url>
  <rule_id>550,553,554</rule_id>
  <alert_format>json</alert_format>
</integration>
```

## Ressources

| Composant | RAM | CPU | Disque |
|-----------|-----|-----|--------|
| Indexer | 2GB min | 2 cores | 50GB+ |
| Manager | 2GB min | 2 cores | 20GB |
| Dashboard | 1GB | 1 core | 5GB |
| **Total** | **8GB min** | **4 cores** | **75GB** |

## Sécurité

1. **Changer les mots de passe par défaut** dans `.env`
2. **Régénérer les certificats** en production
3. **Restreindre l'accès réseau** au port 5601 (dashboard)
4. **Activer MFA** dans le dashboard
5. **Chiffrer les communications** agents (TLS activé par défaut)

## Références

- [Documentation officielle](https://documentation.wazuh.com/)
- [Docker Deployment Guide](https://documentation.wazuh.com/current/deployment-options/docker/index.html)
- [Wazuh GitHub](https://github.com/wazuh/wazuh)
- [Wazuh Ruleset](https://github.com/wazuh/wazuh-ruleset)
- [Wazuh Cloud](https://wazuh.com/cloud/)
