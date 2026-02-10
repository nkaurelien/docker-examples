# JFrog Container Registry (JCR) - Common operations
#
# Usage:
#   make up        Start with Nginx reverse proxy
#   make login     Docker login to registry
#   make push      Tag and push an image
#   make catalog   List all repositories
#   make tags      List tags for an image

REGISTRY ?= registry.localhost
TOKEN    ?=
IMAGE    ?=
TAG      ?= latest

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

.PHONY: up down logs restart status

up: ## Start Artifactory + Nginx (with SSL)
	docker compose -f compose.yml -f compose.nginx.yml up -d

down: ## Stop all services
	docker compose -f compose.yml -f compose.nginx.yml down

logs: ## Tail logs for all services
	docker compose -f compose.yml -f compose.nginx.yml logs -f

restart: down up ## Restart all services

status: ## Show running containers
	docker compose -f compose.yml -f compose.nginx.yml ps

# ---------------------------------------------------------------------------
# SSL
# ---------------------------------------------------------------------------

.PHONY: ssl

ssl: ## Generate SSL certs with mkcert
	bash ssl/generate-certs.sh $(REGISTRY)

# ---------------------------------------------------------------------------
# Docker registry operations
# ---------------------------------------------------------------------------

.PHONY: login push pull catalog tags

login: ## Login to registry (TOKEN required)
	@if [ -z "$(TOKEN)" ]; then \
		echo "Usage: make login TOKEN=<your-identity-token>"; \
		echo "Get a token from: https://$(REGISTRY)/ui/admin/artifactory/user_profile"; \
		exit 1; \
	fi
	@echo "$(TOKEN)" | docker login https://$(REGISTRY) -u admin --password-stdin

push: ## Tag and push an image (IMAGE and TAG required)
	@if [ -z "$(IMAGE)" ]; then echo "Usage: make push IMAGE=myapp TAG=v1.0"; exit 1; fi
	docker tag $(IMAGE):$(TAG) $(REGISTRY)/docker-local/$(IMAGE):$(TAG)
	docker push $(REGISTRY)/docker-local/$(IMAGE):$(TAG)

pull: ## Pull an image (IMAGE and TAG required)
	@if [ -z "$(IMAGE)" ]; then echo "Usage: make pull IMAGE=myapp TAG=v1.0"; exit 1; fi
	docker pull $(REGISTRY)/docker-local/$(IMAGE):$(TAG)

catalog: ## List all repositories in the registry
	@curl -sk https://$(REGISTRY)/v2/_catalog | python3 -m json.tool 2>/dev/null || \
		curl -sk https://$(REGISTRY)/v2/_catalog

tags: ## List tags for IMAGE
	@if [ -z "$(IMAGE)" ]; then echo "Usage: make tags IMAGE=myapp"; exit 1; fi
	@curl -sk https://$(REGISTRY)/v2/docker-local/$(IMAGE)/tags/list | python3 -m json.tool 2>/dev/null || \
		curl -sk https://$(REGISTRY)/v2/docker-local/$(IMAGE)/tags/list

# ---------------------------------------------------------------------------
# JFrog API
# ---------------------------------------------------------------------------

.PHONY: health ping repos

health: ## Check Artifactory health
	@curl -sk https://$(REGISTRY)/router/api/v1/system/health | python3 -m json.tool 2>/dev/null || \
		curl -sk https://$(REGISTRY)/router/api/v1/system/health

ping: ## Ping Artifactory
	@curl -sk https://$(REGISTRY)/artifactory/api/system/ping && echo ""

repos: ## List all repositories (requires TOKEN)
	@if [ -z "$(TOKEN)" ]; then echo "Usage: make repos TOKEN=<token>"; exit 1; fi
	@curl -sk -H "Authorization: Bearer $(TOKEN)" \
		https://$(REGISTRY)/artifactory/api/repositories | python3 -m json.tool 2>/dev/null || \
		curl -sk -H "Authorization: Bearer $(TOKEN)" https://$(REGISTRY)/artifactory/api/repositories

# ---------------------------------------------------------------------------
# Basic (no Nginx)
# ---------------------------------------------------------------------------

.PHONY: up-basic down-basic

up-basic: ## Start Artifactory only (no Nginx, HTTP on 8082)
	docker compose up -d

down-basic: ## Stop Artifactory only
	docker compose down

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help