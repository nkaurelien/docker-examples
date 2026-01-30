# SonarQube Makefile
# Usage: make help

# ==========================================
# CONFIGURATION
# ==========================================

SONAR_COMPOSE = docker compose
SONAR_URL = http://localhost:9000
SONAR_ADMIN_USER = admin
SONAR_ADMIN_PASS = admin

# ==========================================
# SONARQUBE SERVER
# ==========================================

.PHONY: help up down status token scan clean logs

## Show available commands
help:
	@echo "SonarQube Commands:"
	@echo ""
	@echo "  Server:"
	@echo "    make up        - Start SonarQube server"
	@echo "    make down      - Stop SonarQube server"
	@echo "    make status    - Check SonarQube status"
	@echo "    make logs      - View SonarQube logs"
	@echo "    make clean     - Stop and remove all data"
	@echo ""
	@echo "  Authentication:"
	@echo "    make token     - Generate scanner token via API"
	@echo ""
	@echo "  Scanning:"
	@echo "    make scan      - Run code scanner"
	@echo "    make full      - Full workflow (up + token + scan)"
	@echo ""
	@echo "  Security:"
	@echo "    make security-npm     - Audit npm dependencies"
	@echo "    make security-pip     - Audit Python dependencies"
	@echo "    make security-trivy   - Scan Docker image with Trivy"
	@echo ""

## Start SonarQube server
up:
	@echo "🚀 Starting SonarQube server..."
	$(SONAR_COMPOSE) --profile dev up -d
	@echo "⏳ Waiting for SonarQube to be ready (this may take 1-2 minutes)..."
	@until curl -s $(SONAR_URL)/api/system/status | grep -q '"status":"UP"'; do \
		echo "   Still waiting..."; \
		sleep 10; \
	done
	@echo "✅ SonarQube is ready at $(SONAR_URL)"
	@echo "   Default credentials: admin / admin (change on first login)"

## Stop SonarQube server
down:
	@echo "🛑 Stopping SonarQube server..."
	$(SONAR_COMPOSE) --profile dev --profile scan down
	@echo "✅ SonarQube stopped"

## Check SonarQube status
status:
	@echo "📊 SonarQube Status:"
	@curl -s $(SONAR_URL)/api/system/status 2>/dev/null | python3 -m json.tool || echo "❌ SonarQube is not running. Try 'make up'"
	@echo ""
	@echo "🐳 Container Status:"
	@$(SONAR_COMPOSE) --profile dev ps

## View SonarQube logs
logs:
	$(SONAR_COMPOSE) --profile dev logs -f sonarcube

## Generate token via API and save to .env
token:
	@echo "🔑 Generating SonarQube token via API..."
	@TOKEN=$$(curl -s -u $(SONAR_ADMIN_USER):$(SONAR_ADMIN_PASS) \
		-X POST "$(SONAR_URL)/api/user_tokens/generate" \
		-d "name=scanner-token-$$(date +%s)" | \
		grep -o '"token":"[^"]*"' | cut -d'"' -f4); \
	if [ -n "$$TOKEN" ]; then \
		echo "✅ Token generated: $$TOKEN"; \
		if grep -q "^SONAR_TOKEN=" .env 2>/dev/null; then \
			sed -i.bak "s/^SONAR_TOKEN=.*/SONAR_TOKEN=$$TOKEN/" .env && rm -f .env.bak; \
			echo "✅ Token updated in .env"; \
		else \
			echo "SONAR_TOKEN=$$TOKEN" >> .env; \
			echo "✅ Token added to .env"; \
		fi; \
	else \
		echo "❌ Failed to generate token. Is SonarQube running? Try 'make up' first."; \
		echo "   Also check credentials: SONAR_ADMIN_USER=$(SONAR_ADMIN_USER)"; \
		exit 1; \
	fi

## Run code scanner
scan:
	@echo "🔍 Running SonarQube scanner..."
	$(SONAR_COMPOSE) --profile scan up sonar-scanner

## Full workflow: start server, generate token, scan
full:
	@echo "🚀 Running full SonarQube workflow..."
	$(MAKE) up
	@echo ""
	@echo "⚠️  If this is your first login, change the password at $(SONAR_URL)"
	@echo "   Then update SONAR_ADMIN_PASS in Makefile and run 'make token'"
	@echo ""
	$(MAKE) token
	$(MAKE) scan
	@echo "✅ Full scan complete! View results at $(SONAR_URL)"

## Stop and remove all data (volumes)
clean:
	@echo "🧹 Removing SonarQube and all data..."
	$(SONAR_COMPOSE) --profile dev --profile scan down -v
	@echo "✅ SonarQube removed"

# ==========================================
# SECURITY - CVE & Vulnerability Scanning
# ==========================================

## Audit npm dependencies for CVE
security-npm:
	@echo "🔒 Scanning npm dependencies for CVE..."
	@if [ -f yarn.lock ]; then \
		yarn audit --json 2>/dev/null | head -100 || yarn audit || true; \
	elif [ -f package-lock.json ]; then \
		npm audit --json 2>/dev/null | python3 -m json.tool || npm audit || true; \
	else \
		echo "❌ No yarn.lock or package-lock.json found"; \
	fi
	@echo ""
	@echo "💡 To fix: yarn audit fix (or npm audit fix)"

## Audit Python dependencies for CVE
security-pip:
	@echo "🔒 Scanning Python dependencies for CVE..."
	@echo "Using pip-audit (install with: pip install pip-audit)"
	pip-audit || echo "❌ pip-audit not installed. Run: pip install pip-audit"

## Scan Docker image with Trivy
security-trivy:
	@echo "🔒 Scanning Docker images with Trivy..."
	@echo "(Install Trivy: brew install trivy)"
	@if [ -n "$(IMAGE)" ]; then \
		trivy image $(IMAGE); \
	else \
		echo "Usage: make security-trivy IMAGE=your-image:tag"; \
	fi

## Full security scan
security-full:
	@echo "🛡️ Running full security scan..."
	@echo ""
	@echo "=== NPM/Yarn Audit ==="
	-$(MAKE) security-npm
	@echo ""
	@echo "=== Python Audit ==="
	-$(MAKE) security-pip
	@echo ""
	@echo "✅ Security scan complete!"
	@echo ""
	@echo "📋 Recommended additional tools:"
	@echo "   - Trivy (Docker images): brew install trivy"
	@echo "   - Snyk (comprehensive): npm install -g snyk"
	@echo "   - OWASP Dependency-Check: brew install dependency-check"
