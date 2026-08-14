#!/bin/bash
# =============================================================================
# Script: pre-deploy-cleanup.sh
# Description: Nettoyage des ressources Docker avant déploiement
# Usage: ./pre-deploy-cleanup.sh [--dry-run]
# =============================================================================

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Options
DRY_RUN=false
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
    echo -e "${YELLOW}Mode dry-run activé - aucune suppression ne sera effectuée${NC}"
fi

# Seuil d'alerte pour l'espace disque (%)
DISK_THRESHOLD=70

echo "=============================================="
echo "    Nettoyage pré-déploiement Docker"
echo "=============================================="
echo ""

# 1. Vérification de l'espace disque AVANT
echo -e "${YELLOW}[1/5] Vérification de l'espace disque...${NC}"
DISK_USAGE=$(df / | grep -v Filesystem | awk '{print $5}' | sed 's/%//')
DISK_AVAIL=$(df -h / | grep -v Filesystem | awk '{print $4}')

echo "Utilisation actuelle: ${DISK_USAGE}%"
echo "Espace disponible: ${DISK_AVAIL}"

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo -e "${RED}ATTENTION: Disque au-dessus de ${DISK_THRESHOLD}% - Nettoyage recommandé${NC}"
else
    echo -e "${GREEN}OK: Espace disque suffisant${NC}"
fi
echo ""

# 2. État Docker avant nettoyage
echo -e "${YELLOW}[2/5] État Docker avant nettoyage...${NC}"
docker system df
echo ""

# 3. Nettoyage des images non utilisées (> 30 jours)
echo -e "${YELLOW}[3/5] Nettoyage des images Docker (>30 jours)...${NC}"
if [ "$DRY_RUN" = true ]; then
    echo "Images qui seraient supprimées:"
    docker images --filter "dangling=false" --format "{{.Repository}}:{{.Tag}} ({{.Size}}, créée {{.CreatedSince}})" | head -20
else
    docker image prune -a -f --filter 'until=720h'
fi
echo ""

# 4. Nettoyage du cache de build
echo -e "${YELLOW}[4/5] Nettoyage du cache de build...${NC}"
if [ "$DRY_RUN" = true ]; then
    echo "Cache de build qui serait supprimé:"
    docker builder du 2>/dev/null || echo "Pas de cache de build"
else
    docker builder prune -f 2>/dev/null || true
fi
echo ""

# 5. Vérification finale
echo -e "${YELLOW}[5/5] Vérification après nettoyage...${NC}"
if [ "$DRY_RUN" = false ]; then
    NEW_DISK_USAGE=$(df / | grep -v Filesystem | awk '{print $5}' | sed 's/%//')
    NEW_DISK_AVAIL=$(df -h / | grep -v Filesystem | awk '{print $4}')
    FREED=$((DISK_USAGE - NEW_DISK_USAGE))

    echo "Utilisation après: ${NEW_DISK_USAGE}%"
    echo "Espace disponible: ${NEW_DISK_AVAIL}"
    echo -e "${GREEN}Espace libéré: ~${FREED}%${NC}"
    echo ""
    docker system df
fi

echo ""
echo "=============================================="
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Mode dry-run - Exécuter sans --dry-run pour appliquer${NC}"
else
    echo -e "${GREEN}Nettoyage terminé avec succès${NC}"
fi
echo "=============================================="

# Retourner un code d'erreur si le disque est toujours trop plein
if [ "$DRY_RUN" = false ]; then
    FINAL_USAGE=$(df / | grep -v Filesystem | awk '{print $5}' | sed 's/%//')
    if [ "$FINAL_USAGE" -gt 90 ]; then
        echo -e "${RED}ERREUR: Disque toujours à ${FINAL_USAGE}% - Intervention manuelle requise${NC}"
        exit 1
    fi
fi

exit 0
