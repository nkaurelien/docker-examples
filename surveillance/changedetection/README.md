# ChangeDetection.io

Service de surveillance de pages web qui détecte les modifications de contenu et envoie des notifications.

## Services

- **changedetection** : Application principale de monitoring
- **changedetection-browser** : Navigateur headless pour le rendu JavaScript

## Démarrage

```bash
docker compose up -d
```

## Accès

- Interface web : http://localhost:5000

## Configuration

### Variables d'environnement - changedetection

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `PLAYWRIGHT_DRIVER_URL` | URL du navigateur headless | `ws://changedetection-browser:3000` |
| `PLAYWRIGHT_CONNECT_TIMEOUT` | Timeout de connexion au browser (ms) | `120000` |
| `PLAYWRIGHT_NAVIGATION_TIMEOUT` | Timeout de navigation (ms) | `120000` |
| `PLAYWRIGHT_SKIP_BROWSER_INITIALIZATION` | Skip l'init du browser au démarrage | `true` |
| `BASE_URL` | URL publique de l'application | - |
| `HIDE_REFERER` | Masquer le referer HTTP | `true` |
| `MINIMUM_SECONDS_RECHECK_TIME` | Intervalle minimum entre vérifications (s) | `3` |
| `TZ` | Fuseau horaire | `Europe/Paris` |

### Variables d'environnement - changedetection-browser

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `SCREEN_WIDTH` | Largeur écran virtuel | `1920` |
| `SCREEN_HEIGHT` | Hauteur écran virtuel | `1024` |
| `SCREEN_DEPTH` | Profondeur couleur | `16` |
| `ENABLE_DEBUGGER` | Activer le debugger Chrome | `false` |
| `PREBOOT_CHROME` | Pré-démarrer Chrome | `true` |
| `CONNECTION_TIMEOUT` | Timeout connexion (ms) | `300000` |
| `MAX_CONCURRENT_CHROME_PROCESSES` | Sessions Chrome simultanées | `6` |
| `CHROME_REFRESH_TIME` | Intervalle de refresh Chrome (ms) | `600000` |
| `DEFAULT_BLOCK_ADS` | Bloquer les publicités | `true` |
| `DEFAULT_STEALTH` | Mode furtif (anti-détection) | `true` |
| `DEFAULT_IGNORE_HTTPS_ERRORS` | Ignorer erreurs SSL | `true` |

## Volumes

- `./data` : Données persistantes (configurations, historique des changements)

## Ressources

- [Documentation officielle](https://changedetection.io/docs)
- [GitHub](https://github.com/dgtlmoon/changedetection.io)
