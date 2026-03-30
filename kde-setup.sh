#!/bin/bash
# =============================================================================
# Minimal KDE Plasma Setup
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
# KDE Plasma minimal
# =============================================================================
info "Installing minimal KDE Plasma..."
sudo pacman -S --noconfirm \
    plasma-desktop \
    plasma-nm \
    plasma-pa \
    kscreen \
    kde-gtk-config \
    kwayland-integration \
    kwallet-pam \
    libappindicator-gtk3 \
    qt6-wayland \
    plasma-login-manager \
    dolphin \
    kate \
    ark \
    breeze-gtk

# =============================================================================
# Enable plasma-login-manager
# =============================================================================
info "Enabling plasma-login-manager..."
sudo systemctl enable plasmalogin

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  KDE setup complete! Please reboot.        ${NC}"
echo -e "${GREEN}=============================================${NC}"
