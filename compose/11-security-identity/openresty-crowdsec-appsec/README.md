---
tags: appsec, bouncer, crowdsec, docker-compose, nginx, openresty, security, waf
---

# OpenResty + CrowdSec (bouncer Lua + WAF AppSec)

Frontal HTTP OpenResty protégé par CrowdSec : blocage des IP bannies (décisions de la LAPI) et pare-feu applicatif (composant AppSec, patchs virtuels), démontrable en local devant un backend `whoami`.

## Fonctionnalités

- **Bouncer Lua** ([lua-cs-bouncer](https://github.com/crowdsecurity/lua-cs-bouncer)) intégré à OpenResty en `access_by_lua_block` : chaque requête est confrontée aux décisions CrowdSec (mode `stream`, rafraîchies toutes les 10 s).
- **WAF AppSec** : la requête est aussi transmise au composant AppSec de CrowdSec (`:7422`), qui applique les règles `appsec-virtual-patching` et `appsec-generic-rules` et renvoie 403 en cas de correspondance.
- **Détection comportementale** : CrowdSec lit le journal d'accès d'OpenResty (collections `nginx`, `base-http-scenarios`, `http-cve`) et crée des décisions de bannissement.
- **Image construite localement** : archives Lua téléchargées et vérifiées par `sha256sum -c`.
- **Aucun secret versionné** : la clé du bouncer vient du `.env`, la config du bouncer est générée au démarrage.

## Architecture

```
                    client (curl)
                          │ :80
                          ▼
┌──────────────────────────────────────────────┐
│ openresty                                    │
│  access_by_lua → cs.Allow(remote_addr)       │
│   ├─ décision LAPI (cache stream, 10 s) ─────┼──► crowdsec:8080  (LAPI)
│   └─ inspection WAF ─────────────────────────┼──► crowdsec:7422  (AppSec)
│  proxy_pass ──► whoami:80                    │
│  access.log ──► volume openresty-logs ───────┼──► crowdsec (acquis.d/nginx.yaml)
└──────────────────────────────────────────────┘
            réseau Docker dédié : waf-net
```

| Service | Image | Rôle |
|---------|-------|------|
| `crowdsec` | `crowdsecurity/crowdsec:v1.8.1` | LAPI, parsers/scénarios, composant AppSec |
| `openresty` | build local (`./openresty/Dockerfile`) | Reverse proxy + bouncer Lua |
| `whoami` | `traefik/whoami` | Backend de démonstration |

### Fichiers

```
openresty-crowdsec-appsec/
├── docker-compose.yml
├── .env.example
├── crowdsec/
│   ├── acquis.d/
│   │   ├── nginx.yaml          # journal d'accès partagé (type nginx)
│   │   └── appsec.yaml         # composant AppSec sur 0.0.0.0:7422
│   └── config.yaml.local       # api.server.log_level: warning
└── openresty/
    ├── Dockerfile              # OpenResty + lua-cs-bouncer + lua-resty-http
    ├── docker-entrypoint.sh    # génère crowdsec-openresty-bouncer.conf depuis l'env
    ├── nginx.conf              # nginx.conf explicite (include conf.d/*.conf dans http)
    └── conf.d/
        ├── crowdsec.conf       # lua_shared_dict, init_by_lua, init_worker, access_by_lua
        └── default.conf        # site de démo → whoami
```

## Démarrage Rapide

```bash
cp .env.example .env
# Générer la clé partagée LAPI ↔ bouncer
sed -i.bak "s/^CROWDSEC_BOUNCER_KEY=.*/CROWDSEC_BOUNCER_KEY=$(openssl rand -hex 32)/" .env && rm .env.bak

docker compose up -d --build
docker compose ps        # crowdsec doit être « healthy » avant le démarrage d'openresty
```

> **Note** : au premier démarrage CrowdSec télécharge les collections depuis le Hub (accès Internet requis). `DISABLE_ONLINE_API=true` désactive seulement l'enregistrement auprès de l'API centrale (pas de liste de blocage communautaire).

La configuration du bouncer est écrite au démarrage par `docker-entrypoint.sh` dans `/etc/crowdsec/bouncers/crowdsec-openresty-bouncer.conf` :

```ini
ENABLED=true
API_URL=http://crowdsec:8080
API_KEY=<CROWDSEC_BOUNCER_KEY>
MODE=stream
UPDATE_FREQUENCY=10
BOUNCING_ON_TYPE=all
FALLBACK_REMEDIATION=ban
BAN_TEMPLATE_PATH=/var/lib/crowdsec/lua/templates/ban.html
CAPTCHA_TEMPLATE_PATH=/var/lib/crowdsec/lua/templates/captcha.html
APPSEC_URL=http://crowdsec:7422
APPSEC_FAILURE_ACTION=passthrough
```

## Tests

### 1. Requête légitime → 200

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://localhost/
# 200
```

### 2. Patch virtuel AppSec → 403

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://localhost/.env
# 403 (règle crowdsecurity/vpatch-env-access)

docker compose exec crowdsec cscli metrics show appsec
```

### 3. Décision manuelle → 403 puis levée

L'IP vue par OpenResty n'est pas celle de l'hôte mais celle de la passerelle du réseau Docker (ex. `172.18.0.1`, ou `192.168.65.1` sous Docker Desktop). La relever dans le journal :

```bash
docker compose exec openresty tail -n 1 /var/log/openresty/access.log
# 172.18.0.1 - - [..] "GET / HTTP/1.1" 200 ...

docker compose exec crowdsec cscli decisions add --ip 172.18.0.1 --duration 2m --reason "test"
sleep 11   # mode stream : prise en compte au prochain rafraîchissement (10 s)
curl -s -o /dev/null -w '%{http_code}\n' http://localhost/
# 403 (page ban.html)

docker compose exec crowdsec cscli decisions delete --ip 172.18.0.1
```

Variante depuis un conteneur client sur le même réseau :

```bash
docker run --rm --network waf-net curlimages/curl -s -o /dev/null -w '%{http_code}\n' http://openresty/
```

## Exploitation

```bash
docker compose exec crowdsec cscli bouncers list           # bouncer « openresty » + dernière remontée
docker compose exec crowdsec cscli metrics show appsec     # requêtes inspectées / bloquées par AppSec
docker compose exec crowdsec cscli metrics show acquisition # lignes lues dans access.log
docker compose exec crowdsec cscli alerts list
docker compose exec crowdsec cscli decisions list
docker compose exec crowdsec cscli appsec-rules list
docker compose logs -f crowdsec openresty
```

Arrêt et nettoyage :

```bash
docker compose down -v
```

## Démo vs production

| | Démo (ce dossier) | Production |
|---|---|---|
| Réseau | réseau Docker `waf-net`, LAPI/AppSec joints par nom (`crowdsec:8080`, `crowdsec:7422`) | `network_mode: host` pour les deux conteneurs, LAPI/AppSec sur `127.0.0.1` |
| IP client | IP de la passerelle Docker (NAT du port publié) | vraie IP du client (pas de NAT Docker) |
| Config nginx | `nginx.conf` + `conf.d/` du dossier | `/etc/nginx` de l'hôte monté en lecture seule |
| Pilotage | `docker compose` | unité systemd `nginx.service` qui pilote le compose |

### En production

- **`network_mode: host`** : avec un port publié (`-p 80:80`), Docker fait du NAT et OpenResty voit l'IP de la passerelle au lieu de celle du client ; le bouncer bannirait alors tout le monde (ou personne). En mode host, `remote_addr` est la vraie IP et la LAPI/AppSec ne sont exposées que sur `127.0.0.1` (`API_URL=http://127.0.0.1:8080`, `APPSEC_URL=http://127.0.0.1:7422`, `listen_addr: 127.0.0.1:7422`). Derrière un CDN/load balancer, configurer `set_real_ip_from` + `real_ip_header`.
- **Config hôte** : `/etc/nginx` (vhosts, certificats) reste sur l'hôte et est monté en lecture seule dans le conteneur ; seuls le binaire OpenResty et le bouncer Lua viennent de l'image.
- **systemd** : une unité `nginx.service` (`ExecStart=docker compose up`, `ExecStop=docker compose down`, `ExecReload=docker compose exec openresty openresty -s reload`) conserve les habitudes d'exploitation (`systemctl reload nginx`) tout en exécutant le frontal en conteneur.
- **CAPI** : retirer `DISABLE_ONLINE_API=true` et enregistrer l'instance (`cscli capi register`, `cscli console enroll`) pour bénéficier de la liste de blocage communautaire.

## Limites

- **AppSec par défaut = patchs virtuels** : `appsec-default` bloque des CVE connues et des accès sensibles (`/.env`, `.git`...). Les injections SQL ou traversées de répertoire génériques ne sont **pas** bloquées sans les règles OWASP CRS (`crowdsecurity/appsec-crs`, en mode hors bande ou bloquant).
- **HTTP uniquement** : le bouncer OpenResty ne protège que le trafic qui passe par OpenResty. Pour SSH ou les autres ports, ajouter un bouncer pare-feu (`crowdsec-firewall-bouncer` nftables/iptables) sur l'hôte.
- **Copie depuis macOS** : une archive `tar` ou une copie vers un disque non-APFS peut ajouter des fichiers `._*.yaml` dans `crowdsec/acquis.d/` ; CrowdSec tente de les lire et s'arrête (`string was used where mapping is expected`). Les supprimer (`find . -name '._*' -delete`) ou copier avec `COPYFILE_DISABLE=1 tar …`.
- **IP privées en liste blanche** : la collection `crowdsecurity/linux` inclut le parser `whitelists` (RFC 1918, loopback) ; en démo, les scénarios comportementaux ne bannissent donc pas l'IP de la passerelle Docker. Les décisions manuelles et les blocages AppSec s'appliquent quand même.
- **Logs** : CrowdSec écrit ses journaux sur stderr (`docker compose logs crowdsec`), pas dans un fichier.
- **`APPSEC_FAILURE_ACTION=passthrough`** : si le composant AppSec est injoignable, les requêtes passent (disponibilité privilégiée) ; mettre `ban` pour un comportement fail-closed.

## Références

- [Bouncer OpenResty](https://docs.crowdsec.net/u/bouncers/openresty)
- [CrowdSec AppSec](https://docs.crowdsec.net/docs/next/appsec/intro)
- [crowdsecurity/lua-cs-bouncer](https://github.com/crowdsecurity/lua-cs-bouncer)
- [Image Docker CrowdSec](https://hub.docker.com/r/crowdsecurity/crowdsec)
