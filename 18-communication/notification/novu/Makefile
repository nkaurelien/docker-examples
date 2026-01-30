# Novu Notification Platform Makefile

.PHONY: help setup up down start stop restart logs logs-api logs-worker logs-ws logs-dashboard logs-db logs-redis logs-minio status ps shell shell-api shell-worker shell-db clean backup health generate-secrets test-api

# Default environment file
ENV_FILE := .env

# Include environment variables
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

# Default values if not set in .env
COMPOSE_PROJECT_NAME ?= novu-notification
API_PORT ?= 3000
WS_PORT ?= 3002
DASHBOARD_PORT ?= 4000
MONGO_PORT ?= 27017

help: ## Show this help message
	@echo "Novu Notification Platform Management"
	@echo ""
	@echo "🚀 QUICK START:"
	@echo "  setup         Create .env from .env.example"
	@echo "  generate-secrets  Generate JWT and encryption keys"
	@echo "  up            Start all services"
	@echo "  status        Show service status"
	@echo "  logs          Show all logs"
	@echo ""
	@echo "⚙️  SERVICE MANAGEMENT:"
	@echo "  up            Start all services"
	@echo "  down          Stop and remove services"
	@echo "  start         Start stopped services"
	@echo "  stop          Stop services (keep containers)"
	@echo "  restart       Restart all services"
	@echo "  ps            Show running containers"
	@echo "  status        Show detailed service status"
	@echo ""
	@echo "📋 LOGS & DEBUG:"
	@echo "  logs          Follow all logs"
	@echo "  logs-api      Follow API logs only"
	@echo "  logs-worker   Follow Worker logs only"
	@echo "  logs-ws       Follow WebSocket logs only"
	@echo "  logs-dashboard Follow Dashboard logs only"
	@echo "  logs-db       Follow MongoDB logs only"
	@echo "  logs-redis    Follow Redis logs only"
	@echo "  logs-minio    Follow MinIO logs only"
	@echo "  shell         Open shell in API container"
	@echo "  shell-api     Open shell in API container"
	@echo "  shell-worker  Open shell in Worker container"
	@echo "  shell-db      Open MongoDB shell"
	@echo "  health        Check service health status"
	@echo ""
	@echo "💾 DATA MANAGEMENT:"
	@echo "  backup        Backup MongoDB and MinIO data"
	@echo "  clean         Remove all data and volumes"
	@echo ""
	@echo "🔐 SECURITY:"
	@echo "  generate-secrets  Generate JWT and encryption keys"
	@echo ""
	@echo "🧪 TESTING:"
	@echo "  test-api      Test API health endpoint"

env-check: ## Check if .env file exists
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "⚠️  Error: $(ENV_FILE) file not found!"; \
		echo "Run 'make setup' to create it from .env.example"; \
		exit 1; \
	fi

setup: ## Create .env from .env.example
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✅ .env file created from .env.example"; \
		echo ""; \
		echo "⚠️  IMPORTANT: Edit .env and set:"; \
		echo "  1. Secure passwords for MongoDB, Redis, and MinIO"; \
		echo "  2. Generate secrets: make generate-secrets"; \
		echo "  3. Configure URLs and ports"; \
		echo ""; \
		echo "Then run: make up"; \
	else \
		echo "⚠️  .env file already exists"; \
	fi

generate-secrets: ## Generate JWT and encryption keys
	@echo "🔐 Generated Secrets:"
	@echo ""
	@echo "JWT_SECRET=$$(openssl rand -hex 32)"
	@echo "STORE_ENCRYPTION_KEY=$$(openssl rand -hex 32)"
	@echo "NOVU_SECRET_KEY=$$(openssl rand -hex 32)"
	@echo ""
	@echo "Add these to your .env file"

up: env-check ## Start all services
	@echo "🚀 Starting Novu notification platform..."
	docker-compose up -d
	@echo ""
	@echo "✅ Services starting..."
	@echo "   Dashboard: http://localhost:$(DASHBOARD_PORT)"
	@echo "   API: http://localhost:$(API_PORT)"
	@echo "   WebSocket: http://localhost:$(WS_PORT)"
	@echo "   MinIO Console: http://localhost:9001"
	@echo ""
	@echo "⏳ Waiting for services to be ready..."
	@sleep 10
	@make status

down: ## Stop and remove services
	@echo "🛑 Stopping Novu services..."
	docker-compose down
	@echo "✅ Services stopped"

start: ## Start stopped services
	docker-compose start

stop: ## Stop services (keep containers)
	docker-compose stop

restart: ## Restart all services
	@echo "🔄 Restarting Novu services..."
	docker-compose restart
	@sleep 5
	@make status

logs: ## Follow all logs
	docker-compose logs -f

logs-api: ## Follow API logs only
	docker-compose logs -f api

logs-worker: ## Follow Worker logs only
	docker-compose logs -f worker

logs-ws: ## Follow WebSocket logs only
	docker-compose logs -f ws

logs-dashboard: ## Follow Dashboard logs only
	docker-compose logs -f dashboard

logs-db: ## Follow MongoDB logs only
	docker-compose logs -f mongodb

logs-redis: ## Follow Redis logs only
	docker-compose logs -f redis

logs-minio: ## Follow MinIO logs only
	docker-compose logs -f minio

status: ## Show detailed service status
	@echo "📊 Service Status:"
	@docker-compose ps
	@echo ""
	@echo "🏥 Health Status:"
	@docker-compose ps --format json | jq -r '.[] | "\(.Name): \(.Health)"' 2>/dev/null || docker-compose ps

ps: ## Show running containers
	docker-compose ps

shell: env-check ## Open shell in API container
	docker-compose exec api sh

shell-api: env-check ## Open shell in API container
	docker-compose exec api sh

shell-worker: env-check ## Open shell in Worker container
	docker-compose exec worker sh

shell-db: env-check ## Open MongoDB shell
	@echo "Connecting to MongoDB as $(MONGO_INITDB_ROOT_USERNAME)..."
	docker-compose exec mongodb mongosh \
		"mongodb://$(MONGO_INITDB_ROOT_USERNAME):$(MONGO_INITDB_ROOT_PASSWORD)@localhost:27017/novu-db?authSource=admin"

health: ## Check service health
	@echo "🏥 Checking service health..."
	@echo ""
	@echo "API:"
	@curl -f http://localhost:$(API_PORT)/v1/health 2>/dev/null && echo "  ✅ API is healthy" || echo "  ❌ API is not responding"
	@echo ""
	@echo "MongoDB:"
	@docker-compose exec -T mongodb mongosh --quiet --eval "db.adminCommand('ping').ok" "mongodb://$(MONGO_INITDB_ROOT_USERNAME):$(MONGO_INITDB_ROOT_PASSWORD)@localhost:27017/admin?authSource=admin" >/dev/null 2>&1 && echo "  ✅ MongoDB is healthy" || echo "  ❌ MongoDB is not responding"
	@echo ""
	@echo "Redis:"
	@docker-compose exec -T redis redis-cli ping >/dev/null 2>&1 && echo "  ✅ Redis is healthy" || echo "  ❌ Redis is not responding"
	@echo ""
	@echo "MinIO:"
	@curl -f http://localhost:9000/minio/health/live 2>/dev/null >/dev/null && echo "  ✅ MinIO is healthy" || echo "  ❌ MinIO is not responding"

backup: env-check ## Backup MongoDB and MinIO data
	@echo "💾 Creating backup..."
	@mkdir -p ./backups
	@BACKUP_DIR="./backups/novu-backup-$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$BACKUP_DIR"; \
	echo "  📦 Backing up MongoDB..."; \
	docker-compose exec -T mongodb mongodump \
		--uri="mongodb://$(MONGO_INITDB_ROOT_USERNAME):$(MONGO_INITDB_ROOT_PASSWORD)@localhost:27017/novu-db?authSource=admin" \
		--archive > "$$BACKUP_DIR/mongodb.archive" 2>/dev/null; \
	echo "  📦 Backing up MinIO data..."; \
	docker-compose exec -T minio tar czf - -C /data . 2>/dev/null > "$$BACKUP_DIR/minio.tar.gz" || true; \
	echo "✅ Backup created: $$BACKUP_DIR"

clean: ## Remove all data and volumes (⚠️  DESTRUCTIVE)
	@echo "⚠️  WARNING: This will delete all Novu data, workflows, templates, and subscribers!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	docker-compose down -v
	rm -rf mongodb/ minio_data/
	@echo "✅ All data cleaned"

test-api: env-check ## Test API health endpoint
	@echo "🧪 Testing API..."
	@curl -v http://localhost:$(API_PORT)/v1/health 2>&1 | grep -E "(HTTP|ok|status)" || echo "❌ API test failed"

# Default target
all: help
