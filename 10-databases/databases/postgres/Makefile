# PostgreSQL with Automated Backups Makefile

.PHONY: help setup up down start stop restart logs logs-db logs-pgadmin logs-ofelia ps status shell-db shell-psql backup-now backup-list backup-restore backup-service-start backup-service-stop backup-service-status clean import export health pgadmin-start pgadmin-stop

# Default environment file
ENV_FILE := .env

# Include environment variables
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

# Default values
COMPOSE_PROJECT_NAME ?= postgres
POSTGRES_PORT ?= 5432
PGADMIN_PORT ?= 5050

help: ## Show this help message
	@echo "PostgreSQL with Automated Backups"
	@echo ""
	@echo "🚀 QUICK START:"
	@echo "  setup         Create .env from .env.example"
	@echo "  up            Start PostgreSQL"
	@echo "  backup-now    Create database backup immediately"
	@echo "  logs          Show all logs"
	@echo ""
	@echo "⚙️  SERVICE MANAGEMENT:"
	@echo "  up            Start PostgreSQL service"
	@echo "  down          Stop and remove all services"
	@echo "  start         Start stopped services"
	@echo "  stop          Stop services (keep containers)"
	@echo "  restart       Restart all services"
	@echo "  ps            Show running containers"
	@echo "  status        Show detailed service status"
	@echo ""
	@echo "📋 LOGS & DEBUG:"
	@echo "  logs          Follow all logs"
	@echo "  logs-db       Follow PostgreSQL logs only"
	@echo "  logs-pgadmin  Follow pgAdmin logs only"
	@echo "  logs-ofelia   Follow Ofelia scheduler logs"
	@echo "  shell-db      Open PostgreSQL container shell"
	@echo "  shell-psql    Open psql interactive terminal"
	@echo "  health        Check services health status"
	@echo ""
	@echo "💾 BACKUP MANAGEMENT:"
	@echo "  backup-now    Create database backup immediately"
	@echo "  backup-list   List all available backups"
	@echo "  backup-restore Restore database from latest backup"
	@echo "  export        Export database manually"
	@echo "  import        Import database manually"
	@echo ""
	@echo "⏰ AUTOMATED BACKUP (Ofelia):"
	@echo "  backup-service-start   Start Ofelia backup scheduler"
	@echo "  backup-service-stop    Stop Ofelia backup scheduler"
	@echo "  backup-service-status  Show Ofelia scheduler status"
	@echo ""
	@echo "🛠️  TOOLS:"
	@echo "  pgadmin-start  Start pgAdmin web interface"
	@echo "  pgadmin-stop   Stop pgAdmin"
	@echo ""
	@echo "🧹 CLEANUP:"
	@echo "  clean         Remove all data and volumes (⚠️  DESTRUCTIVE)"
	@echo ""
	@echo "🌐 ACCESS:"
	@echo "  PostgreSQL: localhost:$(POSTGRES_PORT)"
	@echo "  pgAdmin:    http://localhost:$(PGADMIN_PORT) (requires pgadmin-start)"

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
		echo "  - PostgreSQL credentials (POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB)"; \
		echo "  - Backup schedule (BACKUP_SCHEDULE)"; \
		echo "  - Backup mode (BACKUP_ALL_DBS)"; \
		echo "  - Ports if needed (POSTGRES_PORT, PGADMIN_PORT)"; \
		echo ""; \
		echo "Then run: make up"; \
	else \
		echo "⚠️  .env file already exists"; \
	fi

up: env-check ## Start PostgreSQL service
	@echo "🚀 Starting PostgreSQL..."
	docker-compose up -d postgres
	@echo ""
	@echo "✅ PostgreSQL starting..."
	@echo "   Connection: localhost:$(POSTGRES_PORT)"
	@echo "   Database:   $(POSTGRES_DB)"
	@echo "   User:       $(POSTGRES_USER)"
	@echo ""
	@echo "⏳ Waiting for service to be ready..."
	@sleep 10
	@make status

down: ## Stop and remove all services
	@echo "🛑 Stopping all services..."
	docker-compose --profile backup --profile tools down
	@echo "✅ Services stopped"

start: ## Start stopped services
	docker-compose start

stop: ## Stop services (keep containers)
	docker-compose stop

restart: ## Restart all services
	@echo "🔄 Restarting services..."
	docker-compose restart
	@sleep 5
	@make status

logs: ## Follow all logs
	docker-compose logs -f

logs-db: ## Follow PostgreSQL logs only
	docker-compose logs -f postgres

logs-pgadmin: ## Follow pgAdmin logs only
	docker-compose logs -f pgadmin

logs-ofelia: ## Follow Ofelia scheduler logs
	docker-compose logs -f ofelia

ps: ## Show running containers
	docker-compose ps

status: ## Show detailed service status
	@echo "📊 Service Status:"
	@docker-compose ps
	@echo ""
	@echo "🏥 Health Status:"
	@docker-compose ps --format json | jq -r '.[] | "\(.Name): \(.Health)"' 2>/dev/null || docker-compose ps

shell-db: env-check ## Open PostgreSQL container shell
	docker-compose exec postgres sh

shell-psql: env-check ## Open psql interactive terminal
	@echo "Connecting to PostgreSQL database: $(POSTGRES_DB)"
	docker-compose exec postgres psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

health: ## Check services health
	@echo "🏥 Checking services health..."
	@echo ""
	@echo "PostgreSQL:"
	@docker-compose exec -T postgres pg_isready -U $(POSTGRES_USER) >/dev/null 2>&1 && echo "  ✅ PostgreSQL is healthy" || echo "  ❌ PostgreSQL is not responding"

backup-now: env-check ## Create database backup immediately
	@echo "💾 Creating database backup..."
	docker-compose run --rm dbexport
	@echo ""
	@echo "✅ Backup completed"
	@make backup-list

export: backup-now ## Export database manually (alias for backup-now)

backup-list: ## List all available backups
	@echo "📦 Available Backups:"
	@if [ -d "./backups" ]; then \
		ls -lh ./backups/postgres_*.sql.gz 2>/dev/null | tail -10 || echo "  No backups found"; \
		echo ""; \
		TOTAL_SIZE=$$(du -sh ./backups 2>/dev/null | cut -f1 || echo "0"); \
		BACKUP_COUNT=$$(find ./backups -name "postgres_*.sql.gz" -type f 2>/dev/null | wc -l | tr -d ' '); \
		echo "Total backups: $$BACKUP_COUNT"; \
		echo "Total size: $$TOTAL_SIZE"; \
	else \
		echo "  No backup directory found"; \
	fi

backup-restore: env-check ## Restore database from latest backup
	@echo "⚠️  WARNING: This will replace the current database!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@echo ""
	docker-compose run --rm dbimport

import: backup-restore ## Import database manually (alias for backup-restore)

backup-service-start: env-check ## Start Ofelia backup scheduler
	@echo "⏰ Starting Ofelia backup scheduler..."
	docker-compose --profile backup up -d ofelia
	@sleep 2
	@make backup-service-status

backup-service-stop: ## Stop Ofelia backup scheduler
	@echo "🛑 Stopping Ofelia backup scheduler..."
	docker-compose stop ofelia
	@echo "✅ Ofelia stopped"

backup-service-status: ## Show Ofelia scheduler status
	@echo "⏰ Ofelia Backup Scheduler Status:"
	@docker-compose ps ofelia
	@echo ""
	@echo "📋 Recent Ofelia Logs:"
	@docker-compose logs --tail 10 ofelia | grep -E "(NOTICE|job registered|Starting scheduler|Running job)" || echo "  No logs available"

pgadmin-start: env-check ## Start pgAdmin web interface
	@echo "🚀 Starting pgAdmin..."
	docker-compose --profile tools up -d pgadmin
	@sleep 3
	@echo ""
	@echo "✅ pgAdmin started"
	@echo "   URL: http://localhost:$(PGADMIN_PORT)"
	@echo "   Email: $(PGADMIN_EMAIL)"
	@echo "   Password: $(PGADMIN_PASSWORD)"
	@echo ""
	@echo "To add PostgreSQL server in pgAdmin:"
	@echo "  Host: postgres"
	@echo "  Port: 5432"
	@echo "  User: $(POSTGRES_USER)"
	@echo "  Password: $(POSTGRES_PASSWORD)"

pgadmin-stop: ## Stop pgAdmin
	@echo "🛑 Stopping pgAdmin..."
	docker-compose stop pgadmin
	@echo "✅ pgAdmin stopped"

clean: ## Remove all data and volumes (⚠️  DESTRUCTIVE)
	@echo "⚠️  WARNING: This will delete all PostgreSQL data and backups!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	docker-compose --profile backup --profile tools down -v
	rm -rf backups/ init/
	@echo "✅ All data cleaned"

# Default target
all: help
