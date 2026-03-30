#!/bin/bash
# =============================================================================
# Arch Linux Post-Install Base Setup
# https://github.com/pvtpiti/arch-setup
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Must not run as root
[[ $EUID -eq 0 ]] && error "Do not run as root. Run as your user."

# =============================================================================
# pacman.conf optimizations
# =============================================================================
info "Configuring pacman.conf..."
sudo sed -i 's/#Color/Color/' /etc/pacman.conf
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
sudo sed -i '/^ParallelDownloads/a ILoveCandy' /etc/pacman.conf
sudo sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf

# =============================================================================
# reflector
# =============================================================================
info "Installing reflector..."
sudo pacman -S --noconfirm reflector

info "Configuring reflector..."
sudo tee /etc/xdg/reflector/reflector.conf > /dev/null <<EOF
--save /etc/pacman.d/mirrorlist
--country Germany,France,Netherlands
--protocol https
--latest 10
--sort rate
EOF

info "Running reflector..."
sudo systemctl enable --now reflector.timer
sudo reflector --save /etc/pacman.d/mirrorlist --country Germany,France,Netherlands --protocol https --latest 10 --sort rate

# =============================================================================
# System update
# =============================================================================
info "Updating system..."
sudo pacman -Syu --noconfirm

# =============================================================================
# Base packages
# =============================================================================
info "Installing base packages..."
sudo pacman -S --noconfirm \
    pacman-contrib \
    fastfetch \
    nano \
    xdg-utils \
    xdg-user-dirs \
    power-profiles-daemon \
    fish \
    kitty

# =============================================================================
# paccache timer
# =============================================================================
info "Enabling paccache timer..."
sudo systemctl enable --now paccache.timer

# =============================================================================
# power-profiles-daemon
# =============================================================================
info "Enabling power-profiles-daemon..."
sudo systemctl enable --now power-profiles-daemon

# =============================================================================
# xdg-user-dirs
# =============================================================================
info "Creating user directories..."
xdg-user-dirs-update

# =============================================================================
# Fish shell
# =============================================================================
info "Setting fish as default shell..."
chsh -s /usr/bin/fish

# =============================================================================
# Fonts & Emojis & Codecs
# =============================================================================
info "Installing fonts, emojis and codecs..."
sudo pacman -S --noconfirm \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    noto-fonts-extra \
    ttf-liberation \
    ttf-dejavu \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    gstreamer \
    gst-plugins-base \
    gst-plugins-good \
    gst-plugins-bad \
    gst-plugins-ugly \
    gst-libav \
    ffmpeg \
    libva \
    libva-utils

# =============================================================================
# Nvidia
# =============================================================================
info "Installing Nvidia drivers..."
sudo pacman -S --noconfirm \
    nvidia-open-dkms \
    nvidia-utils \
    lib32-nvidia-utils \
    libva-nvidia-driver

info "Enabling nvidia-persistenced..."
sudo systemctl enable nvidia-persistenced

# =============================================================================
# paru (AUR helper)
# =============================================================================
info "Installing paru..."
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ~

info "Configuring paru..."
sudo tee /etc/paru.conf > /dev/null <<EOF
[options]
BottomUp
NewsOnUpgrade
RemoveMake
CleanAfter
EOF

info "Creating yay -> paru symlink..."
sudo ln -sf /usr/bin/paru /usr/local/bin/yay

# =============================================================================
# AUR packages
# =============================================================================
info "Installing AUR packages..."

# Steam
paru -S --noconfirm steam

# Chrome
paru -S --noconfirm google-chrome

# Heroic Games Launcher
paru -S --noconfirm heroic-games-launcher-bin

# ProtonPlus
paru -S --noconfirm protonplus

# ProtonTricks
paru -S --noconfirm protontricks

# Faugus Launcher
paru -S --noconfirm faugus-launcher

# LACT
paru -S --noconfirm lact

info "Enabling lactd..."
sudo systemctl enable --now lactd

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  Setup complete! Please reboot your system.${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
warn "Don't forget to install your DE after reboot!"
