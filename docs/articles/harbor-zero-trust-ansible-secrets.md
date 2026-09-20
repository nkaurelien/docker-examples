# Zero-Trust Secrets Management in IaC: Automating Harbor Registry Deployments with Ansible

*By nkaurelien — DevSecOps & Infrastructure Automation Guide*

---

## Introduction

Hardcoding credentials in Git repositories or infrastructure templates remains a primary vector for security breaches. In container registry deployments like **Harbor**, plain-text leaks of database passwords, secret keys, or administrator logins compromise the entire container supply chain.

This guide details a **Zero-Trust Infrastructure-as-Code (IaC)** pattern using Ansible, local gitignored secret vaults (`.secrets/`), and Systemd service encapsulation to automate secure Harbor deployments.

---

## 1. Secret Isolation Architecture

The core rule of Zero-Trust IaC is complete decoupling of code templates from stateful credentials.

```
docker-examples/
├── .gitignore                      <-- Enforces .secrets/ is NEVER tracked
├── .secrets/
│   ├── harbor-admin-login          <-- Plaintext 'admin'
│   ├── harbor-admin-password       <-- 24-char cryptographic secret
│   ├── harbor-db-password          <-- PostgreSQL secret
│   └── harbor-secret-key           <-- Core encryption key
├── ansible/
│   ├── roles/
│   │   └── harbor/
│   │       ├── defaults/main.yml   <-- Dynamic lookup definitions
│   │       ├── tasks/main.yml      <-- Deployment orchestration
│   │       └── templates/
│   │           └── harbor.yml.j2   <-- Jinja2 template
```

---

## 2. Dynamic Secret Lookups in Ansible (`defaults/main.yml`)

Ansible’s `lookup('file', ...)` plugin evaluates secret files on the control node at execution time, substituting defaults if files do not exist:

```yaml
# ansible/roles/harbor/defaults/main.yml
harbor_admin_username: "{{ lookup('file', playbook_dir + '/../.secrets/harbor-admin-login', errors='ignore') | default('admin', true) | trim }}"
harbor_admin_password: "{{ lookup('file', playbook_dir + '/../.secrets/harbor-admin-password', errors='ignore') | default('<INSERT_HARBOR_ADMIN_PASSWORD>', true) | trim }}"
harbor_db_password: "{{ lookup('file', playbook_dir + '/../.secrets/harbor-db-password', errors='ignore') | default('<INSERT_HARBOR_DB_PASSWORD>', true) | trim }}"
harbor_secret_key: "{{ lookup('file', playbook_dir + '/../.secrets/harbor-secret-key', errors='ignore') | default('<INSERT_HARBOR_SECRET_KEY>', true) | trim }}"
```

---

## 3. Secure Templating & Systemd Hardening

### Jinja2 Templating (`harbor.yml.j2`)

During execution, Ansible renders configuration files with strict file permissions (`0640` owned by root):

```yaml
# Jinja2 template
hostname: {{ harbor_hostname }}

http:
  port: 8080

external_url: https://{{ harbor_hostname }}

harbor_admin_password: {{ harbor_admin_password }}

database:
  password: {{ harbor_db_password }}
  max_idle_conns: 100
  max_open_conns: 900
```

### Systemd Integration (`systemd-service`)

To ensure harbor auto-starts upon host reboots while inheriting environment parameters cleanly:

```ini
[Unit]
Description=Harbor Cloud-Native OCI Registry & Artifact Repository Service
After=network-online.target docker.service
Wants=network-online.target docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/harbor
ExecStart=/usr/bin/docker compose -f docker-compose.yml -f docker-compose.override.yml up -d
ExecStop=/usr/bin/docker compose -f docker-compose.yml -f docker-compose.override.yml down

[Install]
WantedBy=multi-user.target
```

---

## 4. Automated Compliance Auditing with Snyk

To ensure no first-party code or configuration templates contain security vulnerabilities, integrate **Snyk Code Scan** into the deployment pipeline:

```bash
# Snyk security scan for infrastructure code
snyk code test ansible/roles/harbor/
```

### Key Security Benefits

- **Zero Git Leaks**: Zero plain-text secrets in git history (`.secrets/` gitignored).
- **Idempotent Deployments**: Playbook runs update templates only when values change.
- **Supply Chain Protection**: Trivy vulnerability scanning enabled natively for all stored images.
