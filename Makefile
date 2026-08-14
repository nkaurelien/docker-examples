# Docker Examples - Makefile
# Usage: make <target>

.PHONY: help docs docs-serve docs-build docs-deploy clean docker-clean install registry arcane-start open-webui-env open-webui-tunnel open-webui-clean-port

# Default target
help:
	@echo "Docker Examples - Available Commands"
	@echo ""
	@echo "Documentation:"
	@echo "  make docs          - Install dependencies and serve docs locally"
	@echo "  make docs-serve    - Serve documentation locally (port 8000)"
	@echo "  make docs-build    - Build documentation site"
	@echo "  make docs-deploy   - Deploy documentation to GitHub Pages"
	@echo "  make install       - Install documentation dependencies"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-clean  - Remove unused Docker resources"
	@echo "  make docker-prune  - Deep clean Docker (volumes, networks, images)"
	@echo ""
	@echo "Open WebUI & Ollama:"
	@echo "  make open-webui-env        - Create .env file for Open WebUI"
	@echo "  make open-webui-tunnel     - Create SSH tunnel to remote Ollama host"
	@echo "  make open-webui-clean-port - Free port 11434 if bound (kills local Ollama/ssh)"
	@echo ""
	@echo "Utilities:"
	@echo "  make lint          - Run hadolint on all Dockerfiles"
	@echo "  make clean         - Remove generated files"
	@echo ""

# ============================================================================
# Documentation
# ============================================================================

# Install dependencies
install:
	@echo "Installing documentation dependencies..."
	@if command -v uv >/dev/null 2>&1; then \
		uv venv && . .venv/bin/activate && uv pip install -r requirements-docs.txt; \
	else \
		pip install -r requirements-docs.txt; \
	fi

# Serve documentation locally
docs-serve:
	@echo "Serving documentation at http://127.0.0.1:8000"
	@if [ -f .venv/bin/mkdocs ]; then .venv/bin/mkdocs serve; else mkdocs serve; fi

# Build documentation
docs-build: registry
	@echo "Building documentation..."
	@if [ -f .venv/bin/mkdocs ]; then .venv/bin/mkdocs build; else mkdocs build; fi

# Generate Arcane template registry
registry:
	@echo "Generating Arcane templates registry..."
	python3 scripts/generate_registry.py

# Deploy to GitHub Pages
docs-deploy:
	@echo "Deploying documentation to GitHub Pages..."
	@if [ -f .venv/bin/mkdocs ]; then .venv/bin/mkdocs gh-deploy --force; else mkdocs gh-deploy --force; fi

# Install and serve (convenience target)
docs: install docs-serve

# ============================================================================
# Docker Operations
# ============================================================================

# Clean unused Docker resources
docker-clean:
	@echo "Cleaning unused Docker resources..."
	docker system prune -f
	docker volume prune -f

# Deep clean Docker (dangerous - removes everything unused)
docker-prune:
	@echo "WARNING: This will remove all unused Docker resources!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	docker system prune -af --volumes

# List all running services
docker-status:
	@echo "Running containers:"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Show Docker disk usage
docker-usage:
	@echo "Docker disk usage:"
	@docker system df

# ============================================================================
# Linting
# ============================================================================

# Lint all Dockerfiles with hadolint
lint:
	@echo "Linting Dockerfiles..."
	@find . -name "Dockerfile" -o -name "Dockerfile.*" -o -name "*.Dockerfile" | \
		xargs -I {} hadolint {} || true

# Lint with Docker (no local hadolint required)
lint-docker:
	@echo "Linting Dockerfiles with Docker..."
	@find . -name "Dockerfile" -o -name "Dockerfile.*" -o -name "*.Dockerfile" | \
		xargs -I {} docker run --rm -i hadolint/hadolint < {} || true

# ============================================================================
# Utilities
# ============================================================================

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	rm -rf site/
	rm -rf .venv/
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true

# Add local domains to /etc/hosts (requires sudo)
hosts-add:
	@echo "Adding local domains (requires sudo)..."
	@if command -v hostctl >/dev/null 2>&1; then \
		sudo hostctl add domains apps apps.local hub.apps.local \
			db.apps.local mysql.apps.local \
			docker.apps.local portainer.apps.local arcane.apps.local \
			s3.apps.local minio.apps.local \
			kong.apps.local admin.kong.apps.local \
			git.apps.local gitea.apps.local \
			status.apps.local checkmk.apps.local \
			mail.apps.local traefik.apps.local; \
	else \
		echo "hostctl not found. Install from: https://guumaster.github.io/hostctl/"; \
	fi

# Start Arcane and seed its registry
arcane-start:
	@echo "Starting Arcane stack..."
	docker compose -f compose/02-container-orchestration/arcane/compose.yml up -d


# Show project structure
tree:
	@find . -maxdepth 2 -type d -name "[0-9][0-9]-*" | sort | while read dir; do \
		echo "$$dir"; \
		ls -1 "$$dir" 2>/dev/null | sed 's/^/  /'; \
	done

# ============================================================================
# Open WebUI & Ollama Tunnel
# ============================================================================

# Create .env for Open WebUI with host.docker.internal configuration
open-webui-env:
	@echo "Creating .env for Open WebUI..."
	@if [ ! -f compose/06-ai/open-webui/.env ]; then \
		cp compose/06-ai/open-webui/.env.example compose/06-ai/open-webui/.env; \
		sed -i '' 's|OLLAMA_BASE_URL=.*|OLLAMA_BASE_URL=http://host.docker.internal:11434|' compose/06-ai/open-webui/.env 2>/dev/null || \
		sed -i 's|OLLAMA_BASE_URL=.*|OLLAMA_BASE_URL=http://host.docker.internal:11434|' compose/06-ai/open-webui/.env; \
		echo "Created compose/06-ai/open-webui/.env with OLLAMA_BASE_URL=http://host.docker.internal:11434"; \
	else \
		echo "compose/06-ai/open-webui/.env already exists."; \
	fi

# Load custom configurations from Open WebUI's local git-ignored environment file if it exists
-include compose/06-ai/open-webui/.env

# SSH Tunnel Configurations (override on command line or define in compose/06-ai/open-webui/.env)
OLLAMA_HOST ?= $(OLLAMA_SSH_HOST)
OLLAMA_PORT ?= $(OLLAMA_SSH_PORT)
OLLAMA_USER ?= $(OLLAMA_SSH_USER)

# Fallbacks if not set in .env or via command line arguments
OLLAMA_HOST ?= your-remote-ollama-ip
OLLAMA_PORT ?= 22
OLLAMA_USER ?= username

# Establish SSH tunnel to remote Ollama host
open-webui-tunnel:
	@echo "Opening SSH tunnel to $(OLLAMA_HOST) for Ollama..."
	ssh -N -L 11434:localhost:11434 -p $(OLLAMA_PORT) $(OLLAMA_USER)@$(OLLAMA_HOST)

# Kill any processes (local Ollama or old tunnels) listening on port 11434
open-webui-clean-port:
	@echo "Checking for processes on port 11434..."
	@PID=$$(lsof -t -i:11434); \
	if [ -n "$$PID" ]; then \
		echo "Killing processes on port 11434 (PIDs: $$PID)..."; \
		kill -9 $$PID 2>/dev/null || true; \
	else \
		echo "Port 11434 is free."; \
	fi
