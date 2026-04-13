#!/bin/bash
# =============================================================================
# Minimal COSMIC Desktop Setup
# Run after arch-setup.sh
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

[[ $EUID -eq 0 ]] && error "Do not run as root."

# =============================================================================
# COSMIC minimal (no cosmic-store)
# =============================================================================
info "Installing COSMIC Desktop..."
sudo pacman -S --noconfirm \
    cosmic-session \
    cosmic-comp \
    cosmic-panel \
    cosmic-applets \
    cosmic-app-library \
    cosmic-launcher \
    cosmic-workspaces \
    cosmic-bg \
    cosmic-wallpapers \
    cosmic-settings \
    cosmic-settings-daemon \
    cosmic-notifications \
    cosmic-osd \
    cosmic-screenshot \
    cosmic-randr \
    cosmic-greeter \
    cosmic-files \
    cosmic-text-editor \
    cosmic-terminal \
    xdg-desktop-portal-cosmic

# =============================================================================
# Enable cosmic-greeter
# =============================================================================
info "Enabling cosmic-greeter..."
sudo systemctl enable cosmic-greeter

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  COSMIC setup complete! Please reboot.     ${NC}"
echo -e "${GREEN}=============================================${NC}"
