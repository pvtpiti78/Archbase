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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    swaync \
    rofi-wayland \
    ly \
    uwsm \
    qt6-wayland \
    qt6ct \
    qt5ct \
    dolphin \
    ark \
    kate \
    breeze-gtk \
    adw-gtk-theme \
    gnome-keyring \
    gvfs \
    hyprshot \
    pipewire \
    wireplumber

# =============================================================================
# AUR packages
# =============================================================================
info "Installing AUR packages..."
paru -S --noconfirm quickshell-git

# =============================================================================
# ly display manager
# =============================================================================
info "Enabling ly..."
sudo systemctl enable ly@tty1
sudo systemctl disable getty@tty1 2>/dev/null || true

# =============================================================================
# Configs
# =============================================================================
info "Installing configs..."

mkdir -p ~/.config/hypr
mkdir -p ~/.config/quickshell
mkdir -p ~/Bilder/Screenshots

# Hyprland
cp "$SCRIPT_DIR/quickshell-config/hyprland.conf" ~/.config/hypr/hyprland.conf
cp "$SCRIPT_DIR/quickshell-config/hyprpaper.conf" ~/.config/hypr/hyprpaper.conf
cp "$SCRIPT_DIR/quickshell-config/hypridle.conf"  ~/.config/hypr/hypridle.conf

# Quickshell
cp -r "$SCRIPT_DIR/quickshell-config/bar"       ~/.config/quickshell/
cp -r "$SCRIPT_DIR/quickshell-config/powermenu" ~/.config/quickshell/
cp "$SCRIPT_DIR/quickshell-config/shell.qml"    ~/.config/quickshell/
cp "$SCRIPT_DIR/quickshell-config/Theme.qml"    ~/.config/quickshell/

# =============================================================================
# Wallpaper placeholder
# =============================================================================
if [ ! -f ~/Bilder/wallpaper.jpg ]; then
    warn "No wallpaper found at ~/Bilder/wallpaper.jpg"
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
warn "Add a wallpaper to ~/Bilder/wallpaper.jpg"
warn "After reboot: select Hyprland from the ly session menu"
