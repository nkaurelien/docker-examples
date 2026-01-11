.PHONY: help up down restart logs ps init reload renew shell clean setup

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

# Maintenance
shell:
	docker compose exec nginx /bin/sh

clean:
	docker compose down -v
	rm -rf certbot/conf/* certbot/www/*
