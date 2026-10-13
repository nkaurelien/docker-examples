# Jitsi Meet auto-hébergé (JWT, event_sync, TURN optionnel)

.PHONY: help setup up up-turn down restart logs status event-sync token health clean

ENV_FILE := .env
COMPOSE := docker compose
EVENT_SYNC_CFG := config/prosody/config/conf.d/zz-event-sync.cfg.lua

ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

help: ## Liste des cibles
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## Crée .env (secrets générés) et les dossiers de config
	@test -f $(ENV_FILE) || { cp .env.example $(ENV_FILE) && chmod 600 $(ENV_FILE); \
	  for k in JICOFO_AUTH_PASSWORD JVB_AUTH_PASSWORD JWT_APP_SECRET EVENT_SYNC_TOKEN; do \
	    sed -i.bak "s|^$$k=.*|$$k=$$(openssl rand -hex 32)|" $(ENV_FILE); done; rm -f $(ENV_FILE).bak; \
	  echo "✅ .env créé : renseignez PUBLIC_URL, JVB_ADVERTISE_IPS, JWT_APP_ID"; }
	@# web/transcripts lus par le nginx du conteneur, conf.d par l'utilisateur prosody (uid 100) : 0755.
	@mkdir -p config/web config/transcripts config/prosody/config/conf.d config/prosody/prosody-plugins-custom config/jicofo config/jvb
	@chmod 0755 config config/web config/transcripts config/prosody config/prosody/config config/prosody/config/conf.d

up: setup ## Démarre Jitsi (web, prosody, jicofo, jvb)
	$(COMPOSE) up -d

up-turn: setup ## Démarre Jitsi + coturn (profil turn)
	$(COMPOSE) --profile turn up -d

down: ## Arrête la stack
	$(COMPOSE) --profile turn down

restart: ## Redémarre la stack
	$(COMPOSE) restart

logs: ## Suit les logs (SERVICE=prosody pour un seul service)
	$(COMPOSE) logs -f --tail=100 $(SERVICE)

status: ## État des conteneurs
	$(COMPOSE) --profile turn ps

event-sync: ## Active/retire l'envoi des événements de salle (EVENT_SYNC_URL, EVENT_SYNC_TOKEN)
	@if [ -n "$(EVENT_SYNC_URL)" ]; then \
	  python3 -c 'import os,string,sys; print(string.Template(open(sys.argv[1]).read()).substitute(os.environ), end="")' \
	    prosody/event-sync.cfg.lua.template > $(EVENT_SYNC_CFG) && chmod 0644 $(EVENT_SYNC_CFG) && \
	  echo "✅ event_sync → $(EVENT_SYNC_URL)"; \
	else rm -f $(EVENT_SYNC_CFG); echo "event_sync désactivé (EVENT_SYNC_URL vide)"; fi
	$(COMPOSE) restart prosody

token: ## URL de test avec jeton : make token ROOM=salle-test [NAME="Dr X"] [MOD=1]
	@python3 scripts/jwt.py $(ROOM) --name "$(or $(NAME),Test)" $(if $(MOD),--moderator,)

health: ## Vérifie le web et la connexion du videobridge
	@curl -fsS -o /dev/null -w "web: %{http_code}\n" http://$(JITSI_HTTP_BIND):$(JITSI_HTTP_PORT)/ || echo "web: KO"
	@$(COMPOSE) logs --tail=200 jvb | grep -qiE "joined the MUC|Joined MUC|healthy" && echo "jvb: connecté" || echo "jvb: pas encore connecté"

clean: ## Supprime conteneurs ET configuration générée (garde .env)
	$(COMPOSE) --profile turn down -v
	rm -rf config
