# WordPress with MySQL and Automated Backups Makefile

.PHONY: help setup up down start stop restart logs logs-db logs-wp logs-ofelia ps status shell-db shell-wp backup-now backup-list backup-restore backup-service-start backup-service-stop backup-service-status clean import export health

# Default environment file
ENV_FILE := .env

# Include environment variables
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

# Default values
COMPOSE_PROJECT_NAME ?= wordpress
WORDPRESS_PORT ?= 8000
PHPMYADMIN_PORT ?= 8080

help: ## Show this help message
	@echo "WordPress with MySQL and Automated Backups"
	@echo ""
	@echo "🚀 QUICK START:"
	@echo "  setup         Create .env from .env.example"
	@echo "  up            Start WordPress and MySQL"
	@echo "  backup-now    Create database backup immediately"
	@echo "  logs          Show all logs"
	@echo ""
	@echo "⚙️  SERVICE MANAGEMENT:"
	@echo "  up            Start all services (WordPress + MySQL + PHPMyAdmin)"
	@echo "  down          Stop and remove all services"
	@echo "  start         Start stopped services"
	@echo "  stop          Stop services (keep containers)"
	@echo "  restart       Restart all services"
	@echo "  ps            Show running containers"
	@echo "  status        Show detailed service status"
	@echo ""
	@echo "📋 LOGS & DEBUG:"
	@echo "  logs          Follow all logs"
	@echo "  logs-db       Follow MySQL logs only"
	@echo "  logs-wp       Follow WordPress logs only"
	@echo "  logs-ofelia   Follow Ofelia scheduler logs"
	@echo "  shell-db      Open MySQL shell"
	@echo "  shell-wp      Open WordPress container shell"
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
	@echo "🧹 CLEANUP:"
	@echo "  clean         Remove all data and volumes (⚠️  DESTRUCTIVE)"
	@echo ""
	@echo "🌐 ACCESS:"
	@echo "  WordPress:  http://localhost:$(WORDPRESS_PORT)"
	@echo "  PHPMyAdmin: http://localhost:$(PHPMYADMIN_PORT)"

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
		echo "  - MySQL root password (MYSQL_ROOT_PASSWORD)"; \
		echo "  - Database credentials (MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD)"; \
		echo "  - Backup schedule (BACKUP_SCHEDULE)"; \
		echo "  - Ports if needed (WORDPRESS_PORT, PHPMYADMIN_PORT)"; \
		echo ""; \
		echo "Then run: make up"; \
	else \
		echo "⚠️  .env file already exists"; \
	fi

up: env-check ## Start WordPress and MySQL services
	@echo "🚀 Starting WordPress and MySQL..."
	docker-compose up -d db wordpress phpmyadmin
	@echo ""
	@echo "✅ Services starting..."
	@echo "   WordPress:  http://localhost:$(WORDPRESS_PORT)"
	@echo "   PHPMyAdmin: http://localhost:$(PHPMYADMIN_PORT)"
	@echo ""
	@echo "⏳ Waiting for services to be ready..."
	@sleep 10
	@make status

down: ## Stop and remove all services
	@echo "🛑 Stopping all services..."
	docker-compose down
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

logs-db: ## Follow MySQL logs only
	docker-compose logs -f db

logs-wp: ## Follow WordPress logs only
	docker-compose logs -f wordpress

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

shell-db: env-check ## Open MySQL shell
	@echo "Connecting to MySQL..."
	docker-compose exec db mysql -uroot -p$(MYSQL_ROOT_PASSWORD) $(MYSQL_DATABASE)

shell-wp: env-check ## Open WordPress container shell
	docker-compose exec wordpress bash

health: ## Check services health
	@echo "🏥 Checking services health..."
	@echo ""
	@echo "MySQL:"
	@docker-compose exec -T db mysqladmin ping -h localhost -uroot -p$(MYSQL_ROOT_PASSWORD) >/dev/null 2>&1 && echo "  ✅ MySQL is healthy" || echo "  ❌ MySQL is not responding"
	@echo ""
	@echo "WordPress:"
	@curl -f http://localhost:$(WORDPRESS_PORT) >/dev/null 2>&1 && echo "  ✅ WordPress is healthy" || echo "  ❌ WordPress is not responding"
	@echo ""
	@echo "PHPMyAdmin:"
	@curl -f http://localhost:$(PHPMYADMIN_PORT) >/dev/null 2>&1 && echo "  ✅ PHPMyAdmin is healthy" || echo "  ❌ PHPMyAdmin is not responding"

backup-now: env-check ## Create database backup immediately
	@echo "💾 Creating database backup..."
	docker-compose run --rm dbexport
	@echo ""
	@echo "✅ Backup completed"
	@make backup-list

export: backup-now ## Export database manually (alias for backup-now)

backup-list: ## List all available backups
	@echo "📦 Available Backups:"
	@if [ -d "./database/dumps" ]; then \
		ls -lh ./database/dumps/wordpress_*.sql.gz 2>/dev/null | tail -10 || echo "  No backups found"; \
		echo ""; \
		TOTAL_SIZE=$$(du -sh ./database/dumps 2>/dev/null | cut -f1 || echo "0"); \
		BACKUP_COUNT=$$(find ./database/dumps -name "wordpress_*.sql.gz" -type f 2>/dev/null | wc -l | tr -d ' '); \
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

clean: ## Remove all data and volumes (⚠️  DESTRUCTIVE)
	@echo "⚠️  WARNING: This will delete all WordPress files, databases, and backups!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	docker-compose down -v
	rm -rf wordpress/ database/
	@echo "✅ All data cleaned"

# Default target
all: help
