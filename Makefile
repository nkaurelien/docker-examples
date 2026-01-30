# Docker Examples - Makefile
# Usage: make <target>

.PHONY: help docs docs-serve docs-build docs-deploy clean docker-clean install

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
	mkdocs serve

# Build documentation
docs-build:
	@echo "Building documentation..."
	mkdocs build

# Deploy to GitHub Pages
docs-deploy:
	@echo "Deploying documentation to GitHub Pages..."
	mkdocs gh-deploy --force

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
			docker.apps.local portainer.apps.local \
			s3.apps.local minio.apps.local \
			kong.apps.local admin.kong.apps.local \
			git.apps.local gitea.apps.local \
			status.apps.local checkmk.apps.local \
			mail.apps.local traefik.apps.local; \
	else \
		echo "hostctl not found. Install from: https://guumaster.github.io/hostctl/"; \
	fi

# Show project structure
tree:
	@find . -maxdepth 2 -type d -name "[0-9][0-9]-*" | sort | while read dir; do \
		echo "$$dir"; \
		ls -1 "$$dir" 2>/dev/null | sed 's/^/  /'; \
	done
