# n8n Workflow Automation Makefile

.PHONY: help setup up down start stop restart logs logs-n8n logs-db status ps shell shell-db clean backup list-workflows health generate-key

# Default environment file
ENV_FILE := .env

# Include environment variables
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

# Default values if not set in .env
COMPOSE_PROJECT_NAME ?= n8n-automation
N8N_PORT ?= 5678

help: ## Show this help message
	@echo "n8n Workflow Automation Management"
	@echo ""
	@echo "🚀 QUICK START:"
	@echo "  setup         Create .env from .env.example"
	@echo "  up            Start n8n and PostgreSQL"
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
	@echo "  logs-n8n      Follow n8n logs only"
	@echo "  logs-db       Follow PostgreSQL logs only"
	@echo "  shell         Open shell in n8n container"
	@echo "  shell-db      Open shell in PostgreSQL container"
	@echo "  health        Check service health status"
	@echo ""
	@echo "💾 DATA MANAGEMENT:"
	@echo "  backup        Backup workflows and credentials"
	@echo "  list-workflows List workflow files"
	@echo "  clean         Remove all data and volumes"
	@echo ""
	@echo "🔐 SECURITY:"
	@echo "  generate-key  Generate new encryption key"

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
		echo "  - Secure passwords"; \
		echo "  - Generate encryption key: make generate-key"; \
		echo "  - Configure host and webhook URLs"; \
	else \
		echo "⚠️  .env file already exists"; \
	fi

up: env-check ## Start all services
	@echo "🚀 Starting n8n workflow automation..."
	docker-compose up -d
	@echo ""
	@echo "✅ Services starting..."
	@echo "   n8n UI: http://localhost:$(N8N_PORT)"
	@echo ""
	@echo "⏳ Waiting for services to be ready..."
	@sleep 5
	@make status

down: ## Stop and remove services
	@echo "🛑 Stopping n8n services..."
	docker-compose down
	@echo "✅ Services stopped"

start: ## Start stopped services
	docker-compose start

stop: ## Stop services (keep containers)
	docker-compose stop

restart: ## Restart all services
	@echo "🔄 Restarting n8n services..."
	docker-compose restart
	@sleep 3
	@make status

logs: ## Follow all logs
	docker-compose logs -f

logs-n8n: ## Follow n8n logs only
	docker-compose logs -f n8n

logs-db: ## Follow PostgreSQL logs only
	docker-compose logs -f postgres

status: ## Show detailed service status
	@echo "📊 Service Status:"
	@docker-compose ps
	@echo ""
	@echo "🏥 Health Status:"
	@docker-compose ps --format json | jq -r '.[] | "\(.Name): \(.Health)"' 2>/dev/null || docker-compose ps

ps: ## Show running containers
	docker-compose ps

shell: env-check ## Open shell in n8n container
	docker-compose exec n8n /bin/sh

shell-db: env-check ## Open PostgreSQL shell
	docker-compose exec postgres psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

health: ## Check service health
	@echo "🏥 Checking n8n health..."
	@curl -f http://localhost:$(N8N_PORT)/healthz && echo "✅ n8n is healthy" || echo "❌ n8n is not responding"
	@echo ""
	@echo "🏥 Checking PostgreSQL health..."
	@docker-compose exec -T postgres pg_isready -U $(POSTGRES_USER) || echo "❌ PostgreSQL is not ready"

backup: env-check ## Backup workflows and credentials
	@echo "💾 Creating backup..."
	@mkdir -p ./backups
	@BACKUP_DIR="./backups/n8n-backup-$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$BACKUP_DIR"; \
	docker-compose exec -T n8n tar czf - -C /home/node/.n8n workflows credentials 2>/dev/null | tar xzf - -C "$$BACKUP_DIR"; \
	echo "✅ Backup created: $$BACKUP_DIR"

list-workflows: ## List workflow files
	@echo "📋 Workflows:"
	@ls -lh ./workflows/ 2>/dev/null || echo "No workflows directory found"

clean: ## Remove all data and volumes (⚠️  DESTRUCTIVE)
	@echo "⚠️  WARNING: This will delete all n8n data, workflows, and database!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	docker-compose down -v
	rm -rf ./workflows ./credentials
	@echo "✅ All data cleaned"

generate-key: ## Generate new encryption key
	@echo "🔐 Generated Encryption Key:"
	@openssl rand -base64 32
	@echo ""
	@echo "Add this to your .env file as N8N_ENCRYPTION_KEY"

# Default target
all: help
