# ClamAV - Antivirus Open Source

ClamAV est l'antivirus open-source de référence pour scanner fichiers, emails et uploads utilisateurs.

## Cas d'Usage

- **Scanner les uploads** : Protection applications web
- **Serveurs mail** : Intégration avec Docker Mailserver, Mailu
- **CI/CD** : Scan des artefacts de build
- **Partages de fichiers** : Protection Nextcloud, serveurs FTP

## Démarrage Rapide

```bash
cd 11-security-identity/clamav/

# Démarrer ClamAV
docker compose up -d

# Avec l'API REST (pour intégration facile)
docker compose --profile api up -d
```

> Le premier démarrage télécharge les signatures virus (~300MB).

## Architecture

| Service | Port | Description |
|---------|------|-------------|
| `clamav` | 3310 | Daemon clamd (TCP) |
| `clamav-rest` | 8080 | API REST (optionnel) |

## Scanner un Fichier

### Via TCP (clamd)

```bash
# Scanner un fichier
echo "SCAN /scandir/myfile.txt" | nc localhost 3310
```

### Via API REST

```bash
# Scanner un fichier
curl -F "FILES=@/path/to/file.pdf" http://localhost:8080/api/v1/scan

# Réponse
{
  "success": true,
  "data": {
    "result": [{
      "name": "file.pdf",
      "is_infected": false,
      "viruses": []
    }]
  }
}
```

## Intégration Application

### Node.js

```javascript
const FormData = require('form-data');
const axios = require('axios');

async function scanFile(filePath) {
  const form = new FormData();
  form.append('FILES', fs.createReadStream(filePath));

  const response = await axios.post(
    'http://clamav-rest:8080/api/v1/scan',
    form,
    { headers: form.getHeaders() }
  );

  return response.data.data.result[0];
}
```

### Python

```python
import requests

def scan_file(file_path):
    with open(file_path, 'rb') as f:
        response = requests.post(
            'http://clamav-rest:8080/api/v1/scan',
            files={'FILES': f}
        )
    return response.json()['data']['result'][0]
```

## Test avec EICAR

EICAR est un fichier de test antivirus standard (inoffensif).

```bash
# Créer fichier test
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > eicar.txt

# Scanner
curl -F "FILES=@eicar.txt" http://localhost:8080/api/v1/scan
# Résultat: is_infected: true, viruses: ["Win.Test.EICAR_HDB-1"]
```

## Commandes Utiles

```bash
# Version et signatures
docker exec clamav clamscan --version

# Forcer mise à jour signatures
docker exec clamav freshclam

# Scanner un répertoire
docker exec clamav clamscan -r /scandir/

# Statistiques
echo "STATS" | nc localhost 3310
```

## Ressources Requises

| Ressource | Valeur |
|-----------|--------|
| RAM | **3 GB min, 4 GB recommandé** |
| Disque | ~500 MB (signatures) |
| CPU | Modéré pendant scan |

> **Important** : ClamAV charge toutes les signatures en RAM. Moins de 3GB peut causer des instabilités.

## Références

- [Documentation officielle](https://docs.clamav.net/)
- [ClamAV Docker](https://hub.docker.com/r/clamav/clamav)
- [ClamAV REST API](https://github.com/benzino77/clamav-rest)
