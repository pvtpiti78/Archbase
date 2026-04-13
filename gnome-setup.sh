#!/bin/bash
# =============================================================================
# Minimal GNOME Setup
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
# GNOME minimal
# =============================================================================
info "Installing minimal GNOME..."
sudo pacman -S --noconfirm \
    gnome-shell \
    gnome-control-center \
    gnome-tweaks \
    gnome-backgrounds \
    gdm \
    nautilus \
    gnome-text-editor \
    file-roller \
    resources \
    loupe \
    gst-plugin-pipewire \
    xdg-desktop-portal-gnome \
    gnome-keyring \
    gvfs

# =============================================================================
# AUR packages
# =============================================================================
info "Installing AUR packages..."
paru -S --noconfirm extension-manager

# =============================================================================
# Enable GDM
# =============================================================================
info "Enabling GDM..."
sudo systemctl enable gdm

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  GNOME setup complete! Please reboot.      ${NC}"
echo -e "${GREEN}=============================================${NC}"
