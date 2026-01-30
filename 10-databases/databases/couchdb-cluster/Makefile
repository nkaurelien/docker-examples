# CouchDB Cluster Management Makefile

.PHONY: help setup build up up-with-backup down start stop restart logs status clean shell test-cluster backup sync-from-remote sync-specific-db list-backups clean-backups backup-from-remote restore-to-local network manager manager-install dev quick-start quick-start-with-backup backup-service-start backup-service-stop backup-service-logs backup-service-status backup-now

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
	@echo "🏗️  CLUSTER MANAGEMENT:"
	@echo "  setup                   Copy .env.example to .env if needed"
	@echo "  build                   Build/pull CouchDB images"
	@echo "  up                      Start CouchDB cluster (without backup)"
	@echo "  up-with-backup          Start CouchDB cluster with Ofelia backup scheduler"
	@echo "  init-cluster            Initialize CouchDB cluster"
	@echo "  quick-start             Complete setup: network + cluster + init"
	@echo "  quick-start-with-backup Quick start with Ofelia backup scheduler"
	@echo "  status                  Show cluster status"
	@echo "  logs                    Show cluster logs"
	@echo "  restart                 Restart cluster"
	@echo "  stop                    Stop cluster (keep containers)"
	@echo "  down                    Stop and remove cluster"
	@echo "  clean                   Remove containers, networks, volumes"
	@echo ""
	@echo "💾 BACKUP SCHEDULER (Ofelia):"
	@echo "  backup-service-start    Start Ofelia backup scheduler (daily 2 AM)"
	@echo "  backup-service-stop     Stop Ofelia backup scheduler"
	@echo "  backup-service-logs     Show Ofelia scheduler logs"
	@echo "  backup-service-status   Show Ofelia status and jobs"
	@echo "  backup-now              Run backup immediately"
	@echo ""
	@echo "📂 MANUAL BACKUP/SYNC:"
	@echo "  backup                  Backup local databases (one-time)"
	@echo "  backup-from-remote      Backup all databases from remote"
	@echo "  sync-from-remote        Full sync: backup remote + restore local"
	@echo "  sync-specific-db        Sync one specific database"
	@echo "  list-backups            List available backups"
	@echo "  clean-backups           Clean old backups"
	@echo ""
	@echo "🌐 TOOLS & UTILITIES:"
	@echo "  manager                 Launch CouchDB Manager UI"
	@echo "  test-cluster            Test cluster connectivity"
	@echo "  shell                   Open shell in CouchDB node 0"
	@echo "  network                 Create external network if needed"

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

up-with-backup: env-check ## Start CouchDB cluster with Ofelia backup scheduler
	docker-compose --profile backup up -d
	@echo "CouchDB cluster with backup scheduler starting..."
	@echo "Waiting for services to be ready..."
	@sleep 10
	@echo "Cluster nodes available at:"
	@echo "  Node 0: http://localhost:$(PORT_BASE)0"
	@echo "  Node 1: http://localhost:$(PORT_BASE)1"
	@echo "  Node 2: http://localhost:$(PORT_BASE)2"
	@echo "  Manager: http://localhost:8501"
	@echo ""
	@echo "Ofelia backup scheduler is running (daily at 2 AM)"

down: ## Stop and remove CouchDB cluster
	docker-compose --profile backup down

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

shell: ## Open shell in CouchDB node 0
	docker-compose exec couchdb-0 /bin/bash

test-cluster: ## Test cluster connectivity and membership
	@echo "Testing cluster membership..."
	@curl -s "http://$(COUCHDB_USER):$(COUCHDB_PASSWORD)@localhost:$(PORT_BASE)0/_membership" | jq '.' 2>/dev/null || \
		curl -s "http://$(COUCHDB_USER):$(COUCHDB_PASSWORD)@localhost:$(PORT_BASE)0/_membership"


backup: ## Backup local CouchDB data (one-time)
	@echo "Creating one-time backup..."
	@if [ ! -f "$(BACKUP_SCRIPT)" ]; then \
		echo "Error: Backup script not found at $(BACKUP_SCRIPT)"; \
		exit 1; \
	fi
	@backup_dir="backups/manual-backup-$(shell date +%Y%m%d_%H%M%S)"; \
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
		echo "Manual backup completed in $$backup_dir"; \
	else \
		echo "No user databases found on local server"; \
	fi

# Development shortcuts
dev: cluster ## Start development environment (alias for cluster)

# Database Sync/Backup/Restore (using remote DB from backend/.env)
REMOTE_ENV_FILE := ../backend/.env
BACKUP_SCRIPT := ./manage/backup_restore_couchdb.sh

# Extract remote CouchDB URL from backend/.env
REMOTE_COUCHDB_URL := $(shell grep '^REMOTE_COUCHDB_URL=' $(REMOTE_ENV_FILE) 2>/dev/null | head -1 | cut -d'=' -f2)
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
	@read -p "Enter backup directory name: " backup_dir && \
	if [ -d "backups/$$backup_dir" ]; then \
		echo "Restoring from backups/$$backup_dir to local CouchDB..."; \
		find "backups/$$backup_dir" -name "*.json" -type f | while read db_file; do \
			db_name=$$(basename "$$db_file" .json); \
			db_dir=$$(dirname "$$db_file"); \
			echo "Restoring $$db_name from $$db_dir..."; \
			bash $(BACKUP_SCRIPT) -r -H localhost -P $(PORT_BASE)0 -u $(COUCHDB_USER) -p $(COUCHDB_PASSWORD) -d "$$db_name" -i "$$db_dir" -c; \
		done; \
		echo "Restore completed!"; \
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
network: ## Create external network if it doesn't exist
	@docker network inspect asone4health_network >/dev/null 2>&1 || \
		docker network create --driver bridge --subnet=172.19.0.0/24 --gateway=172.19.0.1 asone4health_network

# Streamlit Manager
manager: ## Launch Streamlit CouchDB Manager interface
	@echo "Launching CouchDB Manager..."
	@if [ -d "../backend/.venv" ]; then \
		echo "Using backend virtual environment..."; \
		cd ../backend && uv run streamlit run ../couchdb/couchdb_manager.py --server.port 8501 --server.address localhost; \
	elif command -v uv &> /dev/null; then \
		echo "Running with uv..."; \
		cd ../backend && uv sync && uv run streamlit run ../couchdb/couchdb_manager.py --server.port 8501 --server.address localhost; \
	else \
		if ! command -v streamlit &> /dev/null; then \
			echo "Streamlit not found. Please install backend dependencies first."; \
			echo "Run: cd ../backend && uv sync"; \
			exit 1; \
		fi; \
		streamlit run couchdb_manager.py --server.port 8501 --server.address localhost; \
	fi

manager-install: ## Install Python dependencies via backend
	@echo "Installing Python dependencies via backend..."
	@cd ../backend && uv sync
	@echo "Dependencies installed successfully"

# Quick actions
quick-start: network up init-cluster ## Quick start: create network, start cluster, and initialize

quick-start-with-backup: network up-with-backup ## Quick start with Ofelia backup scheduler
	@echo "CouchDB cluster with backup scheduler is ready!"
	@echo "Access the cluster at http://localhost:$(PORT_BASE)0"
	@echo "Automated backups will run daily at 2 AM"

# Ofelia Backup Scheduler Management
backup-service-start: ## Start Ofelia backup scheduler (daily at 2 AM)
	docker-compose --profile backup up -d ofelia
	@echo "Ofelia backup scheduler started (daily at 2 AM)"

backup-service-stop: ## Stop Ofelia backup scheduler
	docker-compose stop ofelia
	docker-compose rm -f ofelia

backup-service-logs: ## Show Ofelia scheduler logs
	docker-compose logs -f ofelia

backup-service-status: ## Show Ofelia scheduler status
	@echo "Ofelia Container Status:"
	@docker-compose ps ofelia
	@echo ""
	@echo "Recent Ofelia logs (last 10 lines):"
	@docker-compose logs --tail 10 ofelia | grep -E "(NOTICE|job registered|Starting scheduler)" || echo "No job info in recent logs"

backup-now: ## Run backup immediately using existing script
	@echo "Running immediate backup..."
	@docker-compose exec -T \
		-e COUCHDB_USER=$(COUCHDB_USER) \
		-e COUCHDB_PASSWORD=$(COUCHDB_PASSWORD) \
		-e BACKUP_RETENTION_DAYS=$(BACKUP_RETENTION_DAYS) \
		couchdb-0 /opt/scripts/backup-job.sh || \
		echo "Error: CouchDB cluster not running. Start with 'make up' first"

# Default target
all: help