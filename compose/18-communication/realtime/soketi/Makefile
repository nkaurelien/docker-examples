# Soketi — temps réel compatible Pusher (laravel-echo, pusher-js, SDK pusher)

.PHONY: help setup up down restart logs status ready metrics publish webhooks clean

ENV_FILE := .env
COMPOSE := docker compose

ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

SOKETI_PORT ?= 6001
SOKETI_METRICS_PORT ?= 9601
DEMO_PORT ?= 8088
CHANNEL ?= demo-user.42
MSG ?= Nouveau rendez-vous

help: ## Liste des cibles
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

setup: ## Crée .env avec une clé et un secret générés
	@test -f $(ENV_FILE) || { cp .env.example $(ENV_FILE) && chmod 600 $(ENV_FILE); \
	  sed -i.bak "s|^SOKETI_APP_KEY=.*|SOKETI_APP_KEY=$$(openssl rand -hex 16)|" $(ENV_FILE); \
	  sed -i.bak "s|^SOKETI_APP_SECRET=.*|SOKETI_APP_SECRET=$$(openssl rand -hex 32)|" $(ENV_FILE); \
	  rm -f $(ENV_FILE).bak; echo "✅ .env créé (clé et secret générés)"; }

up: setup ## Démarre soketi, redis, webhook-receiver et la page de démo
	$(COMPOSE) up -d
	@echo "Démo : http://localhost:$(DEMO_PORT)"

down: ## Arrête la stack
	$(COMPOSE) down

restart: ## Redémarre la stack
	$(COMPOSE) restart

logs: ## Suit les logs (SERVICE=soketi pour un seul service)
	$(COMPOSE) logs -f --tail=100 $(SERVICE)

status: ## État des conteneurs
	$(COMPOSE) ps

ready: ## Sonde /ready de Soketi
	@curl -fsS -o /dev/null -w "/ready → HTTP %{http_code}\n" http://127.0.0.1:$(SOKETI_PORT)/ready

metrics: ## Extrait des métriques Prometheus
	@curl -fsS http://127.0.0.1:$(SOKETI_METRICS_PORT)/metrics | grep -E '^soketi_(connected|new_connections_total|socket_received)' || true

publish: ## Publie un événement (CHANNEL=demo-user.42 MSG="...")
	$(COMPOSE) run --rm publisher "$(CHANNEL)" "$(MSG)"

webhooks: ## Affiche les webhooks reçus (connecté / déconnecté)
	$(COMPOSE) logs -f --tail=50 webhook-receiver

clean: ## Supprime conteneurs et volume Redis
	$(COMPOSE) down -v
