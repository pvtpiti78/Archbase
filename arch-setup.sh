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
# Enable multilib
# =============================================================================
info "Enabling multilib repository..."
sudo sed -i 's/#\[multilib\]/\[multilib\]/' /etc/pacman.conf
sudo sed -i '/\[multilib\]/{n;s/^#Include/Include/}' /etc/pacman.conf
sudo pacman -Sy --noconfirm

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
    kitty \
    linux-headers \
    networkmanager

# =============================================================================
# paccache timer
# =============================================================================
info "Enabling paccache timer..."
sudo systemctl enable --now paccache.timer

# =============================================================================
# NetworkManager
# =============================================================================
info "Enabling NetworkManager..."
sudo systemctl enable --now NetworkManager

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
# Environment configs
# =============================================================================
info "Writing gaming.conf..."
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/gaming.conf <<'EOF'
### OpenGL
__GL_SYNC_TO_VBLANK=0
__GL_MaxFramesAllowed=1
__GL_GSYNC_ALLOWED=1
__GL_VRR_ALLOWED=1
__GL_SHADER_DISK_CACHE_SIZE=12000000000
### Proton / Wayland
PROTON_ENABLE_NGX_UPDATER=1
PROTON_ENABLE_WAYLAND=1
PROTON_ENABLE_NVAPI=1
PROTON_DLSS_UPGRADE=1
PROTON_USE_NTSYNC=1
PROTON_VKD3D_HEAP=1 
### NTSYNC
WINEFSYNC=0
WINEESYNC=0
### DLSS
DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE=on
DXVK_NVAPI_DRS_NGX_DLSS_SR_MODE=custom
DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_SCALING_RATIO=50
DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_m
### Frame Generation
DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE=on
DXVK_NVAPI_DRS_NGX_DLSSG_MULTI_FRAME_COUNT=3
### Frame Rate Cap
DXVK_FRAME_RATE=237
VKD3D_FRAME_RATE=237
### HDR
DXVK_HDR=1
PROTON_ENABLE_HDR=1
ENABLE_HDR_WSI=1
DXVK_NVAPI_SET_NGX_DEBUG_OPTIONS="DLSSIndicator=1024"
EOF

info "Writing nvidia.conf..."
cat > ~/.config/environment.d/nvidia.conf <<'EOF'
### Vulkan / Wayland / Nvidia
NVD_BACKEND=direct
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
LIBVA_DRIVER_NAME=nvidia
### Electron
ELECTRON_OZONE_PLATFORM_HINT=auto
EOF

#info "Writing chrome-flags.conf..."
#cat > ~/.config/chrome-flags.conf <<'EOF'
#--ozone-platform-hint=auto
#--enable-features=WaylandLinuxDrmSyncobj
#--enable-gpu-rasterization
#--enable-zero-copy
#--ignore-gpu-blocklist
#EOF

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  Setup complete! Please reboot your system.${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
warn "Don't forget to install your DE after reboot!"
