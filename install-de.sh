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
echo -e "  ${GREEN}4)${NC} Niri + Noctalia"
echo -e "  ${GREEN}5)${NC} COSMIC Desktop"
echo ""
read -rp "Choose your DE [1-5]: " choice

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
    4)
        info "Starting Niri + Noctalia setup..."
        chmod +x "$SCRIPT_DIR/niri-setup.sh"
        "$SCRIPT_DIR/niri-setup.sh"
        ;;
    5)
        info "Starting COSMIC Desktop setup..."
        chmod +x "$SCRIPT_DIR/cosmic-setup.sh"
        "$SCRIPT_DIR/cosmic-setup.sh"
        ;;
    *)
        error "Invalid choice. Run the script again and select 1-5."
        ;;
esac
