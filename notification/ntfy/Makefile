# ntfy Notification Service Makefile

.PHONY: help setup up down start stop restart logs status ps shell clean test user-add user-list user-remove health backup

# Default environment file
ENV_FILE := .env

# Include environment variables
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

# Default values if not set in .env
COMPOSE_PROJECT_NAME ?= ntfy-notification
NTFY_PORT ?= 8900

help: ## Show this help message
	@echo "ntfy Notification Service Management"
	@echo ""
	@echo "🚀 QUICK START:"
	@echo "  setup         Create .env from .env.example"
	@echo "  up            Start ntfy service"
	@echo "  status        Show service status"
	@echo "  logs          Show logs"
	@echo ""
	@echo "⚙️  SERVICE MANAGEMENT:"
	@echo "  up            Start ntfy service"
	@echo "  down          Stop and remove service"
	@echo "  start         Start stopped service"
	@echo "  stop          Stop service (keep container)"
	@echo "  restart       Restart service"
	@echo "  ps            Show running container"
	@echo "  status        Show detailed service status"
	@echo ""
	@echo "📋 LOGS & DEBUG:"
	@echo "  logs          Follow logs"
	@echo "  shell         Open shell in container"
	@echo "  health        Check service health"
	@echo ""
	@echo "👥 USER MANAGEMENT:"
	@echo "  user-add      Add new user (requires USERNAME)"
	@echo "  user-list     List all users"
	@echo "  user-remove   Remove user (requires USERNAME)"
	@echo ""
	@echo "💾 DATA MANAGEMENT:"
	@echo "  backup        Backup ntfy data"
	@echo "  clean         Remove all data and volumes"
	@echo ""
	@echo "🧪 TESTING:"
	@echo "  test          Send test notification"

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
		echo "  - Base URL and port"; \
		echo "  - Authentication settings"; \
		echo "  - UID/GID for proper permissions"; \
	else \
		echo "⚠️  .env file already exists"; \
	fi

up: env-check ## Start ntfy service
	@echo "🚀 Starting ntfy notification service..."
	docker-compose up -d
	@echo ""
	@echo "✅ Service starting..."
	@echo "   ntfy UI: http://localhost:$(NTFY_PORT)"
	@echo ""
	@echo "⏳ Waiting for service to be ready..."
	@sleep 3
	@make status

down: ## Stop and remove service
	@echo "🛑 Stopping ntfy service..."
	docker-compose down
	@echo "✅ Service stopped"

start: ## Start stopped service
	docker-compose start

stop: ## Stop service (keep container)
	docker-compose stop

restart: ## Restart service
	@echo "🔄 Restarting ntfy service..."
	docker-compose restart
	@sleep 2
	@make status

logs: ## Follow logs
	docker-compose logs -f

status: ## Show detailed service status
	@echo "📊 Service Status:"
	@docker-compose ps
	@echo ""
	@echo "🏥 Health Status:"
	@docker-compose ps --format json | jq -r '.[] | "\(.Name): \(.Health)"' 2>/dev/null || docker-compose ps

ps: ## Show running container
	docker-compose ps

shell: env-check ## Open shell in ntfy container
	docker-compose exec ntfy sh

health: ## Check service health
	@echo "🏥 Checking ntfy health..."
	@curl -f http://localhost:$(NTFY_PORT)/v1/health 2>/dev/null && echo "✅ ntfy is healthy" || echo "❌ ntfy is not responding"

user-add: env-check ## Add new user (usage: make user-add USERNAME=john)
	@if [ -z "$(USERNAME)" ]; then \
		echo "⚠️  Error: USERNAME not provided"; \
		echo "Usage: make user-add USERNAME=john"; \
		exit 1; \
	fi
	@echo "➕ Adding user: $(USERNAME)"
	docker-compose exec ntfy ntfy user add $(USERNAME)

user-list: env-check ## List all users
	@echo "👥 Users:"
	@docker-compose exec ntfy ntfy user list

user-remove: env-check ## Remove user (usage: make user-remove USERNAME=john)
	@if [ -z "$(USERNAME)" ]; then \
		echo "⚠️  Error: USERNAME not provided"; \
		echo "Usage: make user-remove USERNAME=john"; \
		exit 1; \
	fi
	@echo "➖ Removing user: $(USERNAME)"
	docker-compose exec ntfy ntfy user remove $(USERNAME)

backup: env-check ## Backup ntfy data
	@echo "💾 Creating backup..."
	@mkdir -p ./backups
	@BACKUP_DIR="./backups/ntfy-backup-$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$BACKUP_DIR"; \
	docker-compose exec -T ntfy tar czf - -C /var/cache/ntfy . 2>/dev/null | tar xzf - -C "$$BACKUP_DIR" || true; \
	docker-compose exec -T ntfy tar czf - -C /etc/ntfy . 2>/dev/null | tar xzf - -C "$$BACKUP_DIR" || true; \
	echo "✅ Backup created: $$BACKUP_DIR"

clean: ## Remove all data and volumes (⚠️  DESTRUCTIVE)
	@echo "⚠️  WARNING: This will delete all ntfy data!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	docker-compose down -v
	rm -rf cache/ data/
	@echo "✅ All data cleaned"

test: env-check ## Send test notification
	@echo "📨 Sending test notification..."
	@curl -H "Title: Test Notification" \
	     -H "Priority: high" \
	     -H "Tags: white_check_mark" \
	     -d "This is a test notification from ntfy Makefile at $$(date)" \
	     http://localhost:$(NTFY_PORT)/test
	@echo ""
	@echo "✅ Test notification sent to topic 'test'"
	@echo "   Subscribe at: http://localhost:$(NTFY_PORT)/test"

# Default target
all: help
