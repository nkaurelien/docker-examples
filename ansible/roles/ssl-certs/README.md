# Role `ssl-certs`

Deploie les certificats SSL Namecheap/Sectigo (wildcard) depuis le poste local
vers les serveurs production FR (`asone4health.fr`) et TN (`asone4health.tn`).

Reference : https://www.namecheap.com/support/knowledgebase/article.aspx/9419/33/installing-an-ssl-certificate-on-nginx/

## Prerequis (action dev)

Les fichiers locaux sont dans `.ssl-certs/` (git-ignored). Structure attendue :

```
.ssl-certs/
├── asone4health_fr/
│   ├── __asone4health_fr.crt           # certificat wildcard (requis)
│   ├── __asone4health_fr.ca-bundle     # chaine CA intermediaire (requis)
│   ├── __asone4health_fr.p7b           # bundle PKCS#7 (OPTIONNEL - absent du zip mail)
│   ├── PRIVATE                         # private key extraite du zip CSR Namecheap (requis)
│   └── CSR                             # CSR extraite du zip CSR Namecheap (archive)
└── asone4health_tn/  (idem)
```

Note : le `.p7b` n'est present que dans le zip telecharge depuis le site
Namecheap, pas dans celui envoye par mail. Le role detecte son absence et
skippe le upload sans erreur.

Pour obtenir ces fichiers :

1. Telecharger le cert Namecheap → dezipper dans `.ssl-certs/asone4health_{tld}/`
2. Dezipper le `CSR wilcard.zip` (fourni lors de la demande du CSR) dans le meme dossier

## Usage

### Via Makefile (recommande)

```bash
# Dry-run (voir ce que le playbook modifierait sans toucher au serveur)
SSH_PASS=xxx make deploy-ssl-certs-check-fr
SSH_PASS=xxx make deploy-ssl-certs-check-tn

# Deploiement reel
SSH_PASS=xxx make deploy-ssl-certs-fr
SSH_PASS=xxx make deploy-ssl-certs-tn
```

### Via ansible-playbook direct

```bash
cd ansible/docker-compose-strategy

# Dry-run
ansible-playbook -i inventories/prod-fr.yml deploy-ssl-certs.yml --check --diff --ask-become-pass

# Deploiement reel
ansible-playbook -i inventories/prod-fr.yml deploy-ssl-certs.yml --ask-become-pass
ansible-playbook -i inventories/prod-tn.yml deploy-ssl-certs.yml --ask-become-pass
```

## Fichiers deployes sur le serveur

Tous dans `/etc/ssl/{{ app_domain }}/`. Les noms distants preservent la
convention Namecheap pour coller a l'etat deja en place (FR assemble manuellement).

| Fichier distant | Source locale | Usage |
|---|---|---|
| `nginx_bundle.crt` | `__{tld}.crt` + `__{tld}.ca-bundle` (concat) | cert principal nginx (`ssl_certificate`) |
| `private.key` | `PRIVATE` | clef privee (mode 0600, `ssl_certificate_key`) |
| `__asone4health_{tld}.crt` | idem local | cert seul (source du bundle) |
| `__asone4health_{tld}.ca-bundle` | idem local | chaine CA seule |
| `__asone4health_{tld}.p7b` | idem local | PKCS#7 archive (uploade uniquement si present localement) |
| `apache_bundle.crt` | `__asone4health_{tld}.crt` | alias cert seul pour Apache |
| `{{ app_domain }}.csr` | `CSR` | CSR archivee |

Les chemins `nginx_bundle.crt` et `private.key` correspondent exactement a ce
que les vhosts nginx attendent (`vars/nginx/nginx_vhosts.yml`).

## Renouvellement annuel

1. Telecharger les nouveaux fichiers depuis Namecheap
2. Remplacer `.ssl-certs/asone4health_{fr,tn}/` (le dev dezippe manuellement)
3. Re-run le playbook — idempotent, backup auto des anciens fichiers (`.YYYY-MM-DD@HH-MM~`)
4. Reload nginx declenche uniquement si le contenu change

## Variables principales (`defaults/main.yml`)

| Variable | Defaut | Description |
|---|---|---|
| `ssl_certs_local_dir` | `.ssl-certs/asone4health_{tld}/` | Dossier source |
| `ssl_certs_local_cert_file` | `__asone4health_{tld}.crt` | Nom local du cert |
| `ssl_certs_local_key_file` | `PRIVATE` | Nom local de la clef |
| `ssl_certs_remote_dir` | `/etc/ssl/{{ app_domain }}` | Dossier cible |
| `ssl_certs_remote_nginx_bundle_file` | `nginx_bundle.crt` (= `ssl_cert_file`) | Bundle cible |
| `ssl_certs_validate_key_match` | `true` | Verifier modulus cert == key |
| `ssl_certs_backup_on_replace` | `true` | Backup auto lors du replacement |

Override possible via `-e var=value` sur la ligne de commande.

## Verifications

```bash
# Serveur
ssh asone4health@188.165.198.81 'sudo ls -la /etc/ssl/asone4health.fr/ && sudo nginx -t'

# Client (dates + chaine)
openssl s_client -connect asone4health.fr:443 -servername asone4health.fr -showcerts </dev/null 2>/dev/null \
  | openssl x509 -noout -dates -subject -issuer

# HTTP
curl -I https://doctor.asone4health.fr https://patient.asone4health.fr https://api.asone4health.fr
```
