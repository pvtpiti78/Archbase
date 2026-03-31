#!/bin/bash
# =============================================================================
# Hyprland Setup Script
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
# Packages
# =============================================================================
info "Installing Hyprland stack..."
sudo pacman -S --noconfirm \
    hyprland \
    hyprpaper \
    hypridle \
    hyprlock \
    hyprpolkitagent \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    quickshell \
    swaync \
    rofi-wayland \
    ly \
    uwsm \
    qt6-wayland \
    dolphin \
    kate \
    ark \
    hyprshot

# =============================================================================
# ly display manager
# =============================================================================
info "Enabling ly..."
sudo systemctl enable ly@tty1
sudo systemctl disable getty@tty1

# =============================================================================
# Configs
# =============================================================================
info "Installing configs..."

mkdir -p ~/.config/hypr
mkdir -p ~/.config/quickshell
mkdir -p ~/.config/swaync
mkdir -p ~/Pictures

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Hyprland
cp "$SCRIPT_DIR/hyprland.conf" ~/.config/hypr/hyprland.conf
cp "$SCRIPT_DIR/hyprpaper.conf" ~/.config/hypr/hyprpaper.conf
cp "$SCRIPT_DIR/hypridle.conf" ~/.config/hypr/hypridle.conf

# Quickshell
cp -r "$SCRIPT_DIR/quickshell-config/"* ~/.config/quickshell/

# =============================================================================
# Default wallpaper
# =============================================================================
if [ ! -f ~/Pictures/wallpaper.jpg ]; then
    warn "No wallpaper found at ~/Pictures/wallpaper.jpg"
    warn "Please add a wallpaper there before starting Hyprland."
fi

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  Hyprland setup complete! Please reboot.   ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
warn "Add a wallpaper to ~/Pictures/wallpaper.jpg"
