#!/bin/bash
# =============================================================================
# Archbase DE Installer
# Run after arch-setup.sh
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

[[ $EUID -eq 0 ]] && error "Do not run as root."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Archbase — Desktop Environment Installer  ${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""
echo -e "  ${GREEN}1)${NC} KDE Plasma (minimal)"
echo -e "  ${GREEN}2)${NC} GNOME 50 (minimal)"
echo -e "  ${GREEN}3)${NC} Hyprland + Quickshell"
echo ""
read -rp "Choose your DE [1-3]: " choice

case "$choice" in
    1)
        info "Starting KDE Plasma setup..."
        chmod +x "$SCRIPT_DIR/kde-setup.sh"
        "$SCRIPT_DIR/kde-setup.sh"
        ;;
    2)
        info "Starting GNOME setup..."
        chmod +x "$SCRIPT_DIR/gnome-setup.sh"
        "$SCRIPT_DIR/gnome-setup.sh"
        ;;
    3)
        info "Starting Hyprland setup..."
        chmod +x "$SCRIPT_DIR/hyprland-setup.sh"
        "$SCRIPT_DIR/hyprland-setup.sh"
        ;;
    *)
        error "Invalid choice. Run the script again and select 1, 2 or 3."
        ;;
esac
