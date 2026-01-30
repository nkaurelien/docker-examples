# ClamAV - Open Source Antivirus Engine

Antivirus open-source de référence pour scanner fichiers, emails et uploads.

## Fonctionnalités

- **Scan de fichiers** : Détection virus, malwares, trojans
- **Mise à jour automatique** : Signatures via freshclam
- **API REST** : Intégration facile dans applications
- **Socket TCP/Unix** : Scanning réseau ou local
- **Mail integration** : Compatible avec serveurs mail

## Démarrage Rapide

```bash
# Démarrer ClamAV (daemon + freshclam)
docker compose up -d

# Avec l'API REST
docker compose --profile api up -d
```

> **Note** : Le premier démarrage télécharge les signatures (~300MB) et peut prendre plusieurs minutes.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      ClamAV Stack                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌────────────┐  │
│  │   clamd     │    │  freshclam  │    │  REST API  │  │
│  │  (scanner)  │    │  (updater)  │    │ (optional) │  │
│  │  :3310      │    │             │    │   :8080    │  │
│  └──────┬──────┘    └──────┬──────┘    └─────┬──────┘  │
│         │                  │                  │         │
│         └────────┬─────────┘                  │         │
│                  │                            │         │
│         ┌────────▼────────┐                   │         │
│         │   clamav-db     │◄──────────────────┘         │
│         │ (virus sigs)    │                             │
│         └─────────────────┘                             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Utilisation

### Scanner un fichier via TCP (clamd)

```bash
# Avec clamdscan (si installé)
clamdscan --stream /path/to/file

# Avec netcat
echo "SCAN /scandir/myfile.txt" | nc localhost 3310

# Scanner et obtenir le résultat
echo "nSCAN /scandir/myfile.txt" | nc localhost 3310
```

### Scanner via API REST

```bash
# Vérifier que l'API fonctionne
curl http://localhost:8080/api/v1/version

# Scanner un fichier
curl -F "FILES=@/path/to/file.pdf" http://localhost:8080/api/v1/scan

# Réponse JSON
{
  "success": true,
  "data": {
    "result": [
      {
        "name": "file.pdf",
        "is_infected": false,
        "viruses": []
      }
    ]
  }
}

# Fichier infecté (exemple)
{
  "success": true,
  "data": {
    "result": [
      {
        "name": "eicar.txt",
        "is_infected": true,
        "viruses": ["Win.Test.EICAR_HDB-1"]
      }
    ]
  }
}
```

### Intégration dans une application

#### Node.js
```javascript
const FormData = require('form-data');
const axios = require('axios');
const fs = require('fs');

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

// Usage
const result = await scanFile('./upload.pdf');
if (result.is_infected) {
  console.log('Virus detected:', result.viruses);
  // Delete or quarantine file
}
```

#### Python
```python
import requests

def scan_file(file_path):
    url = 'http://clamav-rest:8080/api/v1/scan'
    with open(file_path, 'rb') as f:
        files = {'FILES': f}
        response = requests.post(url, files=files)
    return response.json()['data']['result'][0]

# Usage
result = scan_file('./upload.pdf')
if result['is_infected']:
    print(f"Virus detected: {result['viruses']}")
```

#### PHP
```php
<?php
function scanFile($filePath) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://clamav-rest:8080/api/v1/scan');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, [
        'FILES' => new CURLFile($filePath)
    ]);

    $response = curl_exec($ch);
    curl_close($ch);

    return json_decode($response, true)['data']['result'][0];
}

// Usage
$result = scanFile('./upload.pdf');
if ($result['is_infected']) {
    echo "Virus detected: " . implode(', ', $result['viruses']);
}
```

## Scanner un répertoire partagé

Montez le répertoire à scanner dans le conteneur :

```yaml
# compose.yml
services:
  clamav:
    volumes:
      # Vos uploads applicatifs
      - /path/to/uploads:/scandir/uploads:ro
      # Plusieurs répertoires possibles
      - /path/to/attachments:/scandir/attachments:ro
```

```bash
# Scanner tout le répertoire
docker exec clamav clamscan -r /scandir/uploads

# Scanner avec rapport
docker exec clamav clamscan -r -i /scandir/uploads --log=/tmp/scan.log
```

## Intégration avec Docker Mailserver

```yaml
# Dans le compose.yml de docker-mailserver
services:
  mailserver:
    environment:
      - ENABLE_CLAMAV=1
      - CLAMAV_MESSAGE_SIZE_LIMIT=25M
    # Utiliser ClamAV externe
    # - CLAMAV_HOST=clamav
    # - CLAMAV_PORT=3310
```

## Test avec EICAR

EICAR est un fichier de test standard pour antivirus (inoffensif).

```bash
# Créer le fichier de test EICAR
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /tmp/eicar.txt

# Copier dans le volume
docker cp /tmp/eicar.txt clamav:/scandir/eicar.txt

# Scanner
docker exec clamav clamscan /scandir/eicar.txt
# Output: /scandir/eicar.txt: Win.Test.EICAR_HDB-1 FOUND

# Via API REST
curl -F "FILES=@/tmp/eicar.txt" http://localhost:8080/api/v1/scan
```

## Commandes Utiles

```bash
# Statut du daemon
docker exec clamav clamdtop

# Version et signatures
docker exec clamav clamscan --version

# Forcer mise à jour des signatures
docker exec clamav freshclam

# Voir les logs
docker logs -f clamav

# Statistiques daemon
echo "STATS" | nc localhost 3310
```

## Configuration

### Limites de scan (clamd.conf)

| Paramètre | Défaut | Description |
|-----------|--------|-------------|
| `MaxScanSize` | 100M | Taille max données scannées par fichier |
| `MaxFileSize` | 25M | Taille max d'un fichier unique |
| `MaxRecursion` | 16 | Profondeur max archives imbriquées |
| `MaxFiles` | 10000 | Nombre max fichiers dans archive |
| `MaxThreads` | 12 | Threads de scan parallèles |

### Mise à jour signatures (freshclam.conf)

| Paramètre | Défaut | Description |
|-----------|--------|-------------|
| `Checks` | 12 | Vérifications par jour (toutes les 2h) |
| `ConnectTimeout` | 30 | Timeout connexion (secondes) |
| `TestDatabases` | yes | Tester avant installation |

## Ressources

- **Mémoire** : **3GB minimum, 4GB recommandé** (signatures chargées en mémoire)
- **Disque** : ~500MB (signatures virus)
- **CPU** : Modéré pendant scan, faible au repos

> **Important** : ClamAV charge toutes les signatures virus en RAM. Avec moins de 3GB, le service peut échouer ou être instable.

## Sécurité

- Monter les répertoires à scanner en **lecture seule** (`:ro`)
- Isoler le réseau ClamAV si possible
- Limiter la taille des fichiers uploadés côté application
- Ne pas exposer le port 3310 publiquement

## Références

- [ClamAV Documentation](https://docs.clamav.net/)
- [ClamAV Docker Hub](https://hub.docker.com/r/clamav/clamav)
- [ClamAV REST API](https://github.com/benzino77/clamav-rest)
- [EICAR Test File](https://www.eicar.org/download-anti-malware-testfile/)
