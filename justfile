# =============================================================================
# Justfile — Operations for Docker Examples & Homelab
# =============================================================================
set shell := ["bash", "-uc"]

HOSTCTL_PROFILE := "homelab"
HOMELAB_IP      := "192.168.1.10"
HOMELAB_TLD     := "example.local"

DOMAINS := "example.local " + \
    "traefik.example.local " + \
    "arcane.example.local " + \
    "auth.example.local " + \
    "passwords.example.local " + \
    "git.example.local " + \
    "share.example.local " + \
    "pad.example.local " + \
    "tools.example.local " + \
    "pdf.example.local " + \
    "draw.example.local " + \
    "logs.example.local " + \
    "status.example.local " + \
    "ntfy.example.local " + \
    "glances.example.local " + \
    "changedetection.example.local"

# Default target: List available recipes
default:
    @just --list

# 🌐 Add example.local homelab domains to /etc/hosts via hostctl
hostctl-add:
    @echo "🌐 Adding {{ HOSTCTL_PROFILE }} local domains to /etc/hosts (IP: {{ HOMELAB_IP }})..."
    @command -v hostctl >/dev/null 2>&1 || { echo "❌ hostctl not found. Install: brew install guumaster/tap/hostctl"; exit 1; }
    @if [ "$(uname -s)" = "Darwin" ]; then \
        osascript -e 'do shell script "hostctl remove {{ HOSTCTL_PROFILE }} 2>/dev/null || true; hostctl add domains {{ HOSTCTL_PROFILE }} --ip {{ HOMELAB_IP }} {{ DOMAINS }}" with administrator privileges'; \
    else \
        sudo hostctl remove {{ HOSTCTL_PROFILE }} 2>/dev/null || true; \
        sudo hostctl add domains {{ HOSTCTL_PROFILE }} --ip {{ HOMELAB_IP }} {{ DOMAINS }}; \
    fi
    @echo "✅ Local domains added for {{ HOMELAB_TLD }}. Verify with: just hostctl-list"

# 🧹 Remove example.local domains from /etc/hosts
hostctl-remove:
    @echo "🧹 Removing {{ HOSTCTL_PROFILE }} domains from /etc/hosts..."
    @command -v hostctl >/dev/null 2>&1 || { echo "❌ hostctl not found. Install: brew install guumaster/tap/hostctl"; exit 1; }
    @if [ "$(uname -s)" = "Darwin" ]; then \
        osascript -e 'do shell script "hostctl remove {{ HOSTCTL_PROFILE }} 2>/dev/null || true" with administrator privileges'; \
    else \
        sudo hostctl remove {{ HOSTCTL_PROFILE }} 2>/dev/null || true; \
    fi
    @echo "✅ {{ HOSTCTL_PROFILE }} domains removed"

# 📋 List all active hostctl profiles
hostctl-list:
    @echo "📋 Current hostctl profiles:"
    @hostctl list 2>/dev/null || echo "❌ hostctl not found."

# 📡 Test Ansible SSH connection to homelab
ansible-ping:
    cd ansible && ansible homelab -m ping

# 📊 Display parsed Ansible inventory JSON
ansible-inventory:
    cd ansible && ansible-inventory -i inventory.yml --list

# 🚀 Execute Ansible deployment playbook on homelab (optionally targeting tags: just ansible-deploy-homelab TAGS="homepage")
ansible-deploy-homelab TAGS="":
    cd ansible && ansible-playbook site.yml -l homelab {{ if TAGS != "" { "--tags " + TAGS } else { "" } }}

