# =============================================================================
# FastAPI - Production Dockerfile 100% Cloud-Native with UV & Multi-Stage
# =============================================================================
# Stage 1: Builder — Installe les dépendances Python avec compilation du bytecode
# Stage 2: Runtime — Image finale minimale, sans compilateur ni outils de build

# -----------------------------------------------------------------------------
# Stage 1: Builder
# -----------------------------------------------------------------------------
FROM python:3.11-slim-bookworm AS builder

# Dépendances système requises pour compiler d'éventuelles extensions C/C++
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    libffi-dev \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Récupération du binaire uv officiel ultra-rapide
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

WORKDIR /app

# Optimisation cache Docker : copie des fichiers de dépendances d'abord
COPY pyproject.toml README.md* requirements.txt* /app/

# Installation des dépendances de production sans dépendances de dev
# Si pyproject.toml est utilisé :
RUN if [ -f pyproject.toml ]; then \
        uv sync --no-dev --compile-bytecode ; \
    elif [ -f requirements.txt ]; then \
        uv venv /app/.venv && uv pip install --no-cache -r requirements.txt ; \
    fi

# -----------------------------------------------------------------------------
# Stage 2: Runtime Cloud-Native
# -----------------------------------------------------------------------------
FROM python:3.11-slim-bookworm AS runtime

# Utilitaires de base pour l'observabilité et probes K8s (sans toolchain C)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copie de l'environnement virtuel pré-compilé et du code source
COPY --from=builder /app/.venv /app/.venv
COPY . /app

# Configuration de l'environnement Python
ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP_ENV=production \
    PORT=8000 \
    HOST=0.0.0.0

# Sécurité : Exécution sous utilisateur non-root (conforme CIS Benchmark & Snyk)
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /bin/sh -M appuser && \
    chown -R appuser:appgroup /app

USER 10001:10001

EXPOSE 8000

# Probe de santé locale
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/healthz || exit 1

# Exécution Uvicorn directe (1 seul worker par Pod - Kubernetes gère le scale)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
