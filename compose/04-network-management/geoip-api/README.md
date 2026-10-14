---
tags: docker-compose, geoip, geolocation, maxmind, networking, rest-api
---

# GeoIP API — géolocalisation d'adresses IP en REST

Service REST qui renvoie le pays, la ville, le fuseau horaire et l'AS (opérateur) d'une adresse IP, à
partir de la base [MaxMind GeoLite2](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data)
embarquée dans l'image ([observabilitystack/geoip-api](https://github.com/observabilitystack/geoip-api)).

Usage typique : enrichir des journaux de connexion (« nouvelle connexion depuis un autre pays »),
alimenter un tableau de bord, ou ajouter des en-têtes de géolocalisation dans un proxy nginx — sans
appeler un service externe à chaque requête.

## Fonctionnalités

- **REST simple** : `GET /<ip>` → JSON.
- **Plusieurs IP** : `POST /` avec une liste JSON.
- **Mode en-têtes** : `X-Geoip-Address` en entrée, `X-Geoip-*` en sortie (intégration nginx `auth_request`).
- **Hors ligne** : base locale, aucune requête sortante.
- **Image hebdomadaire** : code et base GeoLite2 mis à jour chaque semaine (tag `aaaa-SS`).

## Démarrage rapide

```bash
cp .env.example .env
docker compose up -d
docker compose ps          # healthy après ~30 s
```

## Utilisation

```bash
# Une adresse
curl -s http://127.0.0.1:8080/8.8.8.8
# {"country":"US","latitude":"37.751","longitude":"-97.822","continent":"NA",
#  "timezone":"America/Chicago","accuracyRadius":1000,"asn":15169,"asnOrganization":"GOOGLE", ...}

# Plusieurs adresses
curl -s -H 'Content-Type: application/json' -d '["8.8.8.8","1.1.1.1"]' http://127.0.0.1:8080/

# Mode en-têtes (réponse 204, données dans X-Geoip-Country, X-Geoip-City, ...)
curl -sI -H 'X-Geoip-Address: 8.8.8.8' http://127.0.0.1:8080/

# Santé
curl -s http://127.0.0.1:8080/actuator/health
```

Depuis un autre conteneur du même réseau Docker : `http://geoip-api:8080/<ip>`.

## Configuration

| Variable | Défaut | Rôle |
|---|---|---|
| `GEOIP_API_TAG` | `2026-42` | Tag de l'image (année-semaine) |
| `GEOIP_API_BIND` | `127.0.0.1` | Adresse d'écoute sur l'hôte |
| `GEOIP_API_PORT` | `8080` | Port publié sur l'hôte |
| `CITY_DB_FILE` / `ASN_DB_FILE` / `ISP_DB_FILE` | bases GeoLite2 embarquées | Base MaxMind commerciale montée en volume |

## Bonnes pratiques

- **Service interne** : publié sur `127.0.0.1` seulement. Une adresse IP de client est une donnée
  personnelle (RGPD) ; l'exposer publiquement offre aussi un service gratuit à n'importe qui.
- **Tag figé, monté régulièrement** : `latest` donne les données les plus fraîches mais rend les
  déploiements non reproductibles. Figer le tag et le monter chaque mois (ou via Renovate / Dependabot).
- **Précision** : GeoLite2 est approximatif à l'échelle de la ville ; pour de la production exigeante,
  une base GeoIP2 commerciale se monte en volume (voir `docker-compose.yml`).
- **Durcissement** : système de fichiers en lecture seule, `no-new-privileges`, mémoire bornée.

## Liens

- Projet : <https://github.com/observabilitystack/geoip-api>
- Données : MaxMind GeoLite2 (licence CC BY-SA 4.0, attribution requise)
