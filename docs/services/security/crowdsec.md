---
tags: bouncer, crowdsec, engine, security, security-ids, traefik
---

# CrowdSec Security Engine & Traefik Bouncer

[CrowdSec](https://www.crowdsec.net/) is an open-source, collaborative Intrusion Detection System (IDS) and Intrusion Prevention System (IPS). It analyzes logs from Linux system services, SSH, and Traefik to detect malicious behavior and block bad IP addresses across your infrastructure in real time.

## 🏗️ Architecture

```
                                  ┌─────────────────────────────┐
                                  │   CrowdSec Cloud Console    │
                                  │  (Community Threat Intelligence)│
                                  └──────────────▲──────────────┘
                                                 │
┌─────────────────────────────┐   ┌──────────────┴──────────────┐
│       Traefik Proxy         │   │      CrowdSec Engine        │
│   (Access Logs & Bouncer)   ├──►│   (Analyzes Traefik/SSH)    │
└─────────────────────────────┘   └─────────────────────────────┘
```

- **CrowdSec Engine**: Container running `crowdsecurity/crowdsec` parsing log files for attack patterns (SSH brute-force, HTTP probing, path traversal, scanner bots).
- **Traefik Bouncer**: Intercepts requests and queries CrowdSec Local API (LAPI) to block malicious IPs dynamically.

---

## 🚀 Deployment with Ansible

The stack is automated using the Ansible role [`ansible/roles/crowdsec`](https://github.com/nkaurelien/docker-examples/tree/main/ansible/roles/crowdsec):

```bash
make ansible-deploy TAGS=crowdsec
```

---

## 🔐 Configuration & Secrets

All keys are managed in `.secrets/`:

* `.secrets/crowdsec.md` - Documentation for CrowdSec keys.
* `.secrets/crowdsec-lapi-key` - Secret Local API key shared between CrowdSec engine and Traefik bouncer.

---

## 🛠️ CLI Operations (`cscli`)

Run administrative commands inside the `crowdsec` container:

### Check Active Metrics
```bash
docker exec crowdsec cscli metrics
```

### List Banned IPs & Decisions
```bash
docker exec crowdsec cscli decisions list
```

### Manually Ban an IP
```bash
docker exec crowdsec cscli decisions add --ip 192.0.2.1 --reason "Manual ban" --duration 24h
```

### Manually Unban an IP
```bash
docker exec crowdsec cscli decisions delete --ip 192.0.2.1
```

### Check Installed Scenarios & Collections
```bash
docker exec crowdsec cscli collections list
```
