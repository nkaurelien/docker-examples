# CouchDB Cluster Management Makefile

.PHONY: help up down start stop restart logs status clean init-cluster setup env-check build

# Default environment file
ENV_FILE := .env

# Include environment variables
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

# Default values if not set in .env
COMPOSE_PROJECT_NAME ?= couchdb-cluster
PORT_BASE ?= 5984
COUCHDB_USER ?= admin
COUCHDB_PASSWORD ?= admin

help: ## Show this help message
	@echo "CouchDB Cluster Management"
	@echo ""
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

env-check: ## Check if .env file exists
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "Error: $(ENV_FILE) file not found!"; \
		echo "Please copy .env.example to .env and configure your settings."; \
		exit 1; \
	fi

setup: env-check ## Copy .env.example to .env if it doesn't exist
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env file created from .env.example"; \
		echo "Please edit .env with your configuration before proceeding."; \
	else \
		echo ".env file already exists"; \
	fi

build: env-check ## Build/pull CouchDB images
	docker-compose pull

up: env-check ## Start CouchDB cluster in background
	docker-compose up -d
	@echo "CouchDB cluster starting..."
	@echo "Waiting for services to be ready..."
	@sleep 10
	@echo "Cluster nodes available at:"
	@echo "  Node 0: http://localhost:$(PORT_BASE)0"
	@echo "  Node 1: http://localhost:$(PORT_BASE)1"
	@echo "  Node 2: http://localhost:$(PORT_BASE)2"

start: up ## Alias for 'up'

down: ## Stop and remove CouchDB cluster
	docker-compose down

stop: ## Stop CouchDB cluster (keep containers)
	docker-compose stop

restart: env-check ## Restart CouchDB cluster
	docker-compose restart

logs: ## Show CouchDB cluster logs
	docker-compose logs -f

status: ## Show CouchDB cluster status
	@echo "Container Status:"
	@docker-compose ps
	@echo ""
	@echo "Cluster Health:"
	@for i in 0 1 2; do \
		echo -n "Node $$i: "; \
		curl -s -o /dev/null -w "%{http_code}" "http://$(COUCHDB_USER):$(COUCHDB_PASSWORD)@localhost:$(PORT_BASE)$$i/_up" 2>/dev/null || echo "unreachable"; \
		echo ""; \
	done

init-cluster: env-check ## Initialize CouchDB cluster after startup
	@echo "Initializing CouchDB cluster..."
	@chmod +x init-cluster.sh
	@./init-cluster.sh

cluster: up init-cluster ## Start cluster and initialize it
	@echo "CouchDB cluster is ready!"

clean: ## Remove containers, networks, and volumes
	docker-compose down -v --remove-orphans
	@echo "CouchDB cluster cleaned"

clean-all: clean ## Remove everything including images
	docker-compose down -v --remove-orphans --rmi all

shell-0: ## Open shell in CouchDB node 0
	docker-compose exec couchdb-0 /bin/bash

shell-1: ## Open shell in CouchDB node 1
	docker-compose exec couchdb-1 /bin/bash

shell-2: ## Open shell in CouchDB node 2
	docker-compose exec couchdb-2 /bin/bash

test-cluster: ## Test cluster connectivity and membership
	@echo "Testing cluster membership..."
	@curl -s "http://$(COUCHDB_USER):$(COUCHDB_PASSWORD)@localhost:$(PORT_BASE)0/_membership" | jq '.' 2>/dev/null || \
		curl -s "http://$(COUCHDB_USER):$(COUCHDB_PASSWORD)@localhost:$(PORT_BASE)0/_membership"

create-test-db: ## Create a test database
	@echo "Creating test database..."
	@curl -X PUT "http://$(COUCHDB_USER):$(COUCHDB_PASSWORD)@localhost:$(PORT_BASE)0/test-db"

delete-test-db: ## Delete test database
	@echo "Deleting test database..."
	@curl -X DELETE "http://$(COUCHDB_USER):$(COUCHDB_PASSWORD)@localhost:$(PORT_BASE)0/test-db"

backup: ## Backup CouchDB data
	@echo "Creating backup..."
	@mkdir -p backups
	@docker-compose exec -T couchdb-0 couchdb-dump --all-dbs > backups/couchdb-backup-$(shell date +%Y%m%d_%H%M%S).json || \
		echo "Backup command failed. Manual backup may be required."

# Development shortcuts
dev: cluster ## Start development environment (alias for cluster)

dev-logs: ## Follow development logs
	docker-compose logs -f --tail=100

dev-status: status ## Show development status (alias for status)

# Database Sync/Backup/Restore (using remote DB from backend/.env)
REMOTE_ENV_FILE := ../backend/.env
BACKUP_SCRIPT := ./manage/backup_restore_couchdb.sh

# Extract remote CouchDB URL from backend/.env
REMOTE_COUCHDB_URL := $(shell grep '^COUCHDB_URL=' $(REMOTE_ENV_FILE) 2>/dev/null | head -1 | cut -d'=' -f2)
REMOTE_HOST := $(shell echo $(REMOTE_COUCHDB_URL) | sed 's|.*://||' | sed 's|.*@||' | sed 's|:.*||')
REMOTE_PORT := $(shell echo $(REMOTE_COUCHDB_URL) | sed 's|.*:||' | sed 's|/.*||')
REMOTE_USER := $(shell echo $(REMOTE_COUCHDB_URL) | sed 's|.*://||' | sed 's|@.*||' | cut -d':' -f1)
REMOTE_PASSWORD := $(shell echo $(REMOTE_COUCHDB_URL) | sed 's|.*://||' | sed 's|@.*||' | cut -d':' -f2)

env-remote: ## Show remote database configuration
	@echo "Remote CouchDB Configuration (from backend/.env):"
	@echo "  URL: $(REMOTE_COUCHDB_URL)"
	@echo "  Host: $(REMOTE_HOST)"
	@echo "  Port: $(REMOTE_PORT)"
	@echo "  User: $(REMOTE_USER)"
	@echo "  Password: [HIDDEN]"

backup-from-remote: ## Backup all databases from remote CouchDB
	@echo "Backing up from remote CouchDB..."
	@if [ ! -f "$(BACKUP_SCRIPT)" ]; then \
		echo "Error: Backup script not found at $(BACKUP_SCRIPT)"; \
		exit 1; \
	fi
	@if [ -z "$(REMOTE_COUCHDB_URL)" ]; then \
		echo "Error: COUCHDB_URL not found in $(REMOTE_ENV_FILE)"; \
		exit 1; \
	fi
	@backup_dir="backups/remote-backup-$(shell date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$backup_dir"; \
	echo "Getting database list from remote..."; \
	dbs=$$(curl -s -u "$(REMOTE_USER):$(REMOTE_PASSWORD)" "http://$(REMOTE_HOST):$(REMOTE_PORT)/_all_dbs" | jq -r '.[]' | grep -v '^_'); \
	if [ -n "$$dbs" ]; then \
		echo "Found databases: $$dbs"; \
		echo "$$dbs" | while read -r db_name; do \
			if [ -n "$$db_name" ]; then \
				echo "Backing up database: $$db_name"; \
				bash $(BACKUP_SCRIPT) -b -H $(REMOTE_HOST) -P $(REMOTE_PORT) -u $(REMOTE_USER) -p $(REMOTE_PASSWORD) -d "$$db_name" -o "$$backup_dir"; \
			fi; \
		done; \
		echo "Backup completed in $$backup_dir"; \
	else \
		echo "No user databases found on remote server"; \
	fi

restore-to-local: ## Restore databases from backup to local CouchDB
	@echo "Available backups:"
	@ls -la backups/ 2>/dev/null || echo "No backups found"
	@echo ""
	@read -p "Enter backup directory name: " backup_dir; \
	if [ -d "backups/$$backup_dir" ]; then \
		echo "Restoring from backups/$$backup_dir to local CouchDB..."; \
		for db_file in backups/$$backup_dir/*.json; do \
			if [ -f "$$db_file" ]; then \
				db_name=$$(basename "$$db_file" .json); \
				echo "Restoring $$db_name..."; \
				bash $(BACKUP_SCRIPT) -r -H localhost -P $(PORT_BASE)0 -u $(COUCHDB_USER) -p $(COUCHDB_PASSWORD) -d "$$db_name" -i backups/$$backup_dir -c; \
			fi; \
		done; \
	else \
		echo "Backup directory not found: backups/$$backup_dir"; \
	fi

sync-from-remote: backup-from-remote restore-to-local ## Full sync: backup from remote and restore to local

sync-specific-db: ## Sync a specific database from remote to local
	@read -p "Enter database name to sync: " db_name; \
	if [ -n "$$db_name" ]; then \
		echo "Syncing $$db_name from remote to local..."; \
		mkdir -p backups/temp-sync-$(shell date +%Y%m%d_%H%M%S); \
		backup_dir="backups/temp-sync-$(shell date +%Y%m%d_%H%M%S)"; \
		echo "Backing up $$db_name from remote..."; \
		bash $(BACKUP_SCRIPT) -b -H $(REMOTE_HOST) -P $(REMOTE_PORT) -u $(REMOTE_USER) -p $(REMOTE_PASSWORD) -d "$$db_name" -o "$$backup_dir"; \
		echo "Restoring $$db_name to local..."; \
		bash $(BACKUP_SCRIPT) -r -H localhost -P $(PORT_BASE)0 -u $(COUCHDB_USER) -p $(COUCHDB_PASSWORD) -d "$$db_name" -i "$$backup_dir" -c; \
		echo "Cleaning up temporary backup..."; \
		rm -rf "$$backup_dir"; \
		echo "Sync of $$db_name completed!"; \
	else \
		echo "No database name provided"; \
	fi

backup-local: ## Backup local CouchDB databases
	@echo "Backing up local CouchDB..."
	@backup_dir="backups/local-backup-$(shell date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$backup_dir"; \
	echo "Getting local database list..."; \
	dbs=$$(curl -s -u "$(COUCHDB_USER):$(COUCHDB_PASSWORD)" "http://localhost:$(PORT_BASE)0/_all_dbs" | jq -r '.[]' | grep -v '^_'); \
	if [ -n "$$dbs" ]; then \
		echo "Found databases: $$dbs"; \
		echo "$$dbs" | while read -r db_name; do \
			if [ -n "$$db_name" ]; then \
				echo "Backing up database: $$db_name"; \
				bash $(BACKUP_SCRIPT) -b -H localhost -P $(PORT_BASE)0 -u $(COUCHDB_USER) -p $(COUCHDB_PASSWORD) -d "$$db_name" -o "$$backup_dir"; \
			fi; \
		done; \
		echo "Backup completed in $$backup_dir"; \
	else \
		echo "No user databases found on local server"; \
	fi

list-backups: ## List available backups
	@echo "Available backups:"
	@if [ -d "backups" ]; then \
		echo ""; \
		for backup_dir in backups/*/; do \
			if [ -d "$$backup_dir" ]; then \
				dir_name=$$(basename "$$backup_dir"); \
				file_count=$$(find "$$backup_dir" -name "*.json" -type f 2>/dev/null | wc -l | tr -d ' '); \
				size=$$(du -sh "$$backup_dir" 2>/dev/null | cut -f1 || echo "?"); \
				echo "  📁 $$dir_name ($$file_count files, $$size)"; \
				for sub_dir in "$$backup_dir"*/; do \
					if [ -d "$$sub_dir" ] && [ "$$sub_dir" != "$$backup_dir*/" ]; then \
						sub_name=$$(basename "$$sub_dir"); \
						sub_file_count=$$(find "$$sub_dir" -name "*.json" -type f 2>/dev/null | wc -l | tr -d ' '); \
						sub_size=$$(du -sh "$$sub_dir" 2>/dev/null | cut -f1 || echo "?"); \
						echo "    📁 $$dir_name/$$sub_name ($$sub_file_count files, $$sub_size)"; \
					fi; \
				done; \
			fi; \
		done; \
		echo ""; \
		echo "Total backup directories: $$(find backups -maxdepth 1 -type d ! -path backups 2>/dev/null | wc -l | tr -d ' ')"; \
	else \
		echo "No backups directory found"; \
	fi

clean-backups: ## Clean old backups (keep last 5)
	@echo "Cleaning old backups (keeping last 5)..."
	@cd backups && ls -t | tail -n +6 | xargs -r rm -rf
	@echo "Cleanup completed"

# Network management
network-create: ## Create external network if it doesn't exist
	@docker network inspect asone4health_network >/dev/null 2>&1 || \
		docker network create --driver bridge --subnet=172.19.0.0/24 --gateway=172.19.0.1 asone4health_network

network-remove: ## Remove external network
	@docker network rm asone4health_network 2>/dev/null || echo "Network doesn't exist or is in use"

# Quick actions
quick-start: network-create up init-cluster ## Quick start: create network, start cluster, and initialize

# Default target
all: help