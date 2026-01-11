.PHONY: help up down restart logs ps init reload renew shell clean setup cert cert-staging nginx-start

# Configuration
DOMAIN ?= example.com
EMAIL ?= admin@example.com

# Default target
help:
	@echo "Nginx + Certbot - Commandes disponibles"
	@echo ""
	@echo "  make up        - Démarrer les services"
	@echo "  make down      - Arrêter les services"
	@echo "  make restart   - Redémarrer les services"
	@echo "  make logs      - Voir les logs (Ctrl+C pour quitter)"
	@echo "  make ps        - État des conteneurs"
	@echo ""
	@echo "  make init      - Initialiser le certificat Let's Encrypt"
	@echo "  make cert DOMAIN=example.com EMAIL=admin@example.com"
	@echo "               - Générer un certificat pour un domaine"
	@echo "  make reload    - Recharger la config Nginx"
	@echo "  make renew     - Forcer le renouvellement du certificat"
	@echo ""
	@echo "  make setup     - Créer les répertoires nécessaires"
	@echo "  make shell     - Shell dans le conteneur Nginx"
	@echo "  make clean     - Supprimer les conteneurs et volumes"

# Setup
setup:
	@mkdir -p nginx/conf.d certbot/conf certbot/www
	@echo "Répertoires créés ✓"

# Démarrer nginx seul (pour générer les certificats)
nginx-start: setup
	@echo "Démarrage de Nginx seul (sans SSL)..."
	docker run -d --rm --name nginx-certbot \
		-p 80:80 \
		-v "$(PWD)/certbot/www:/var/www/certbot:ro" \
		-v "$(PWD)/nginx/conf.d:/etc/nginx/conf.d:ro" \
		nginx:latest
	@echo "Nginx démarré sur le port 80 ✓"

nginx-stop:
	docker stop nginx-certbot 2>/dev/null || true

# Services
up: setup
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

ps:
	docker compose ps

# SSL / Certbot
init: setup
	./init-letsencrypt.sh

reload:
	docker compose exec nginx nginx -s reload

renew:
	docker compose run --rm certbot renew
	docker compose exec nginx nginx -s reload

# Générer un certificat pour un domaine spécifique
# Usage: make cert DOMAIN=example.com EMAIL=admin@example.com
cert: setup
	@echo "Génération du certificat pour $(DOMAIN)..."
	docker run --rm \
		-v "$(PWD)/certbot/conf:/etc/letsencrypt" \
		-v "$(PWD)/certbot/www:/var/www/certbot" \
		certbot/certbot certonly \
		--webroot \
		--webroot-path=/var/www/certbot \
		-d $(DOMAIN) \
		--email $(EMAIL) \
		--agree-tos \
		--no-eff-email
	@echo "Certificat généré pour $(DOMAIN) ✓"

# Certificat staging (test)
# Usage: make cert-staging DOMAIN=example.com
cert-staging: setup
	@echo "Génération du certificat STAGING pour $(DOMAIN)..."
	docker run --rm \
		-v "$(PWD)/certbot/conf:/etc/letsencrypt" \
		-v "$(PWD)/certbot/www:/var/www/certbot" \
		certbot/certbot certonly \
		--webroot \
		--webroot-path=/var/www/certbot \
		-d $(DOMAIN) \
		--staging \
		--register-unsafely-without-email \
		--agree-tos
	@echo "Certificat STAGING généré pour $(DOMAIN) ✓"

# Maintenance
shell:
	docker compose exec nginx /bin/sh

clean:
	docker compose down -v
	rm -rf certbot/conf/* certbot/www/*
