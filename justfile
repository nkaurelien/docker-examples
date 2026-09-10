# =============================================================================
# Justfile — Operations for Docker Examples & KamitBrains Homelab
# =============================================================================
set shell := ["bash", "-uc"]

HOSTCTL_PROFILE := "kamitbrains-homelab"
HOMELAB_IP      := "192.168.0.210"
HOMELAB_TLD     := "kamitbrains.local"

DOMAINS := "kamitbrains.local " + \
    "traefik.kamitbrains.local " + \
    "arcane.kamitbrains.local " + \
    "auth.kamitbrains.local " + \
    "passwords.kamitbrains.local " + \
    "git.kamitbrains.local " + \
    "share.kamitbrains.local " + \
    "pad.kamitbrains.local " + \
    "tools.kamitbrains.local " + \
    "pdf.kamitbrains.local " + \
    "draw.kamitbrains.local " + \
    "logs.kamitbrains.local " + \
    "status.kamitbrains.local " + \
    "ntfy.kamitbrains.local " + \
    "glances.kamitbrains.local " + \
    "changedetection.kamitbrains.local"

# Default target: List available recipes
default:
    @just --list

# 🌐 Add kamitbrains.local homelab domains to /etc/hosts via hostctl
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

# 🧹 Remove kamitbrains.local domains from /etc/hosts
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

# 🚀 Execute Ansible deployment playbook on homelab
ansible-deploy-homelab:
    cd ansible && ansible-playbook site.yml -l homelab
