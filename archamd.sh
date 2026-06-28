#!/bin/bash
# =============================================================================
# Arch Linux Post-Install Base Setup
# https://github.com/pvtpiti/arch-setup
#
# Prerequisites (install manually before running this script):
#   sudo pacman -S git base-devel
# =============================================================================

set -euo pipefail

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# pacman.conf optimizations
# =============================================================================
info "Configuring pacman.conf..."
sudo sed -i 's/#Color/Color/' /etc/pacman.conf
sudo sed -i 's/ParallelDownloads = .*/ParallelDownloads = 10/' /etc/pacman.conf
grep -q 'ILoveCandy' /etc/pacman.conf || sudo sed -i '/^ParallelDownloads/a ILoveCandy' /etc/pacman.conf
sudo sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf

# =============================================================================
# makepkg optimizations
# =============================================================================
info "Optimizing makepkg for parallel builds..."
sudo sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j\$(nproc)\"/" /etc/makepkg.conf

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
    starship \
    steam \
    protontricks \
    lact \
    linux-zen-headers \
    mesa \
    lib32-mesa \
    vulkan-radeon \
    lib32-vulkan-radeon \
    vulkan-icd-loader \
    lib32-vulkan-icd-loader \
    libva-mesa-driver \
    mesa-vdpau \
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
# Fish config
# =============================================================================
info "Writing fish config..."
mkdir -p ~/.config/fish
cat > ~/.config/fish/config.fish <<'EOF'
# Starship prompt
starship init fish | source

# Fastfetch on start
if status is-interactive
    fastfetch
end

# Aliases
alias ll='ls -lh'
alias la='ls -lah'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias update='paru -Syu'
alias hardclean='sudo bash -c "rm -rf /var/cache/pacman/pkg/download-*" && sudo pacman -Scc && paru -Sc'
EOF

# =============================================================================
# Starship config
# =============================================================================
info "Writing starship config..."
mkdir -p ~/.config
cat > ~/.config/starship.toml <<'EOF'
format = """
$directory\
$git_branch\
$git_status\
$cmd_duration\
$line_break\
$character"""

[directory]
style = "bold #7aa2f7"
truncation_length = 3
truncate_to_repo = true
format = "[$path]($style) "

[git_branch]
symbol = " "
style = "bold #bb9af7"
format = "[$symbol$branch]($style) "

[git_status]
style = "bold #f7768e"
format = "[$all_status$ahead_behind]($style) "
conflicted = "⚡"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?"
modified = "!"
staged = "+"
deleted = "✘"

[cmd_duration]
min_time = 3_000
style = "bold #e0af68"
format = "[ $duration]($style) "

[character]
success_symbol = "[❯](bold #9ece6a)"
error_symbol = "[❯](bold #f7768e)"

[package]
disabled = true

[python]
disabled = true

[nodejs]
disabled = true

[rust]
disabled = true
EOF

# =============================================================================
# Kitty config
# =============================================================================
info "Writing kitty config..."
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf <<'EOF'
# =============================================================================
# Kitty Terminal Configuration
# Theme: Tokyo Night
# =============================================================================

# Font
font_family      JetBrainsMono Nerd Font
bold_font        JetBrainsMono Nerd Font Bold
italic_font      JetBrainsMono Nerd Font Italic
bold_italic_font JetBrainsMono Nerd Font Bold Italic
font_size        13.0

# Tokyo Night Colors
foreground              #c0caf5
background              #1a1b26
selection_foreground    #1a1b26
selection_background    #c0caf5

cursor                  #c0caf5
cursor_text_color       #1a1b26
url_color               #73daca

color0  #15161e
color8  #414868
color1  #f7768e
color9  #f7768e
color2  #9ece6a
color10 #9ece6a
color3  #e0af68
color11 #e0af68
color4  #7aa2f7
color12 #7aa2f7
color5  #bb9af7
color13 #bb9af7
color6  #7dcfff
color14 #7dcfff
color7  #a9b1d6
color15 #c0caf5

# Window
window_padding_width    12
background_opacity      0.95
hide_window_decorations no
remember_window_size    yes

# Cursor
cursor_shape            block
cursor_blink_interval   0

# Scrollback
scrollback_lines        10000

# Performance
repaint_delay           8
input_delay             2
sync_to_monitor         yes

# Bell
enable_audio_bell       no
visual_bell_duration    0.0

# Shell
shell                   /usr/bin/fish
shell_integration       enabled

# Tab bar
tab_bar_style           powerline
tab_powerline_style     slanted
tab_title_template      "{index}: {title}"
active_tab_foreground   #1a1b26
active_tab_background   #7aa2f7
inactive_tab_foreground #a9b1d6
inactive_tab_background #1a1b26

# Keybindings
map ctrl+t              new_tab_with_cwd
map ctrl+w              close_tab
map ctrl+right          next_tab
map ctrl+left           previous_tab
map ctrl+enter          new_window_with_cwd
map ctrl+shift+right    next_window
map ctrl+shift+left     previous_window
map ctrl+equal          change_font_size all +1.0
map ctrl+minus          change_font_size all -1.0
map ctrl+0              change_font_size all 0
map ctrl+shift+k        scroll_page_up
map ctrl+shift+j        scroll_page_down
EOF

# =============================================================================
# Fastfetch config
# =============================================================================
info "Writing fastfetch config..."
mkdir -p ~/.config/fastfetch
cat > ~/.config/fastfetch/config.jsonc <<'EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "type": "builtin",
        "source": "arch"
    },
    "display": {
        "separator": "  "
    },
    "modules": [
        "title",
        "separator",
        {
            "type": "os",
            "key": "OS"
        },
        {
            "type": "kernel",
            "key": "Kernel"
        },
        {
            "type": "uptime",
            "key": "Uptime"
        },
        {
            "type": "packages",
            "key": "Packages"
        },
        "separator",
        {
            "type": "shell",
            "key": "Shell"
        },
        {
            "type": "terminal",
            "key": "Terminal"
        },
        {
            "type": "de",
            "key": "DE/WM"
        },
        "separator",
        {
            "type": "display",
            "key": "Resolution"
        },
        "separator",
        {
            "type": "cpu",
            "key": "CPU"
        },
        {
            "type": "gpu",
            "key": "GPU",
            "driverSpecific": true,
            "format": "{name} [{driver}]"
        },
        {
            "type": "memory",
            "key": "RAM"
        },
        {
            "type": "swap",
            "key": "Swap"
        },
        {
            "type": "disk",
            "key": "Disk",
            "folders": "/"
        },
        "separator",
        {
            "type": "localip",
            "key": "Local IP"
        }
    ]
}
EOF

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
# paru (AUR helper)
# =============================================================================
info "Installing paru..."
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ~

info "Configuring paru..."
sudo sed -i 's/#BottomUp/BottomUp/' /etc/paru.conf
sudo sed -i 's/#NewsOnUpgrade/NewsOnUpgrade/' /etc/paru.conf
sudo sed -i 's/#CleanAfter/CleanAfter/' /etc/paru.conf
sudo sed -i 's/#SudoLoop/SudoLoop/' /etc/paru.conf

info "Creating yay -> paru symlink..."
sudo ln -sf /usr/bin/paru /usr/local/bin/yay

# =============================================================================
# AUR packages
# =============================================================================
info "Installing AUR packages..."
paru -S --noconfirm \
    google-chrome \
    heroic-games-launcher-bin \
    protonplus \
    faugus-launcher \
    shelly-bin

info "Enabling lactd..."
sudo systemctl enable --now lactd

# =============================================================================
# Environment configs
# =============================================================================
info "Writing gaming.conf..."
sudo mkdir -p /etc/environment.d
sudo tee /etc/environment.d/gaming.conf > /dev/null <<'EOF'
### Proton / Wayland
PROTON_ENABLE_WAYLAND=1
PROTON_USE_NTSYNC=1
PROTON_USE_OPTISCALER=1
PROTON_XESS_UPGRADE=1
### NTSYNC — kein esync/fsync
WINEFSYNC=0
WINEESYNC=0
### Optiscaler FSR4 Override Prep & Upgrade
PROTON_FSR4_UPGRADE=1
### Mesa Shader Cache
MESA_SHADER_CACHE_MAX_SIZE=12G
### Frame Rate Cap — 237 FPS (VRR-Dropout-Schutz bei 240Hz)
DXVK_FRAME_RATE=237
VKD3D_FRAME_RATE=237
### HDR (Für Wayland Compositor)
DXVK_HDR=1
PROTON_ENABLE_HDR=1
ENABLE_HDR_WSI=1
EOF

# =============================================================================
# amdgpu.conf ENV
# =============================================================================
info "Writing amdgpu.conf..."
sudo tee /etc/environment.d/amdgpu.conf > /dev/null <<'EOF'
LIBVA_DRIVER_NAME=radeonsi
VDPAU_DRIVER=radeonsi
EOF

# =============================================================================
# sysctl tweaks
# =============================================================================
info "Configuring sysctl..."
sudo tee /etc/sysctl.d/99-gaming.conf > /dev/null <<EOF
vm.max_map_count=2147483642
EOF
sudo sysctl --system > /dev/null

# =============================================================================
# Nautilus Vorlagen (Rechtsklick → Neu erstellen)
# =============================================================================
info "Creating Nautilus templates..."
mkdir -p ~/Vorlagen
touch ~/Vorlagen/"Leere Textdatei.txt"
touch ~/Vorlagen/"Dokument.md"
touch ~/Vorlagen/"Skript.sh"
cat > ~/Vorlagen/"Webseite.html" <<'EOF'
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Titel</title>
</head>
<body>

</body>
</html>
EOF

# =============================================================================
# Desktop Environment
# =============================================================================

echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  Desktop Environment wählen:               ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo "  1) KDE Plasma"
echo "  2) GNOME"
echo "  3) Hyprland"
echo "  4) Niri + Noctalia"
echo "  5) COSMIC"
echo "  6) Kein Desktop"
echo ""
read -rp "Auswahl [1-6]: " de_choice

case "$de_choice" in
    1)
        info "Installiere KDE Plasma..."
        bash "$SCRIPT_DIR/kde-setup.sh"
        ;;
    2)
        info "Installiere GNOME..."
        bash "$SCRIPT_DIR/gnome-setup.sh"
        ;;
    3)
        info "Installiere Hyprland..."
        [[ -f "$SCRIPT_DIR/hyprland-setup.tar.gz" ]] || error "hyprland-setup.tar.gz nicht gefunden in $SCRIPT_DIR"
        tar -xzf "$SCRIPT_DIR/hyprland-setup.tar.gz" -C "$SCRIPT_DIR"
        bash "$SCRIPT_DIR/hyprland-setup.sh"
        ;;
    4)
        info "Installiere Niri + Noctalia..."
        bash "$SCRIPT_DIR/niri-setup.sh"
        ;;
    5)
        info "Installiere COSMIC..."
        bash "$SCRIPT_DIR/cosmic-setup.sh"
        ;;
    6)
        info "Kein Desktop gewählt."
        ;;
    *)
        warn "Ungültige Auswahl — kein Desktop installiert."
        ;;
esac

# =============================================================================
# sched-ext (scx) Scheduler
# =============================================================================
info "Installiere scx-scheds und scx-tools..."
sudo pacman -S --noconfirm \
    scx-scheds \
    scx-tools

info "Schreibe scx_loader.toml (scx_cosmos, Auto-Modus)..."
sudo tee /etc/scx_loader.toml > /dev/null <<'EOF'
default_sched = "scx_cosmos"
default_mode = "Auto"
EOF

info "Aktiviere scx_loader..."
sudo systemctl enable --now scx_loader.service

# =============================================================================
# falcond (Fan Control)
# =============================================================================
info "Installiere falcond und falcond-gui..."
paru -S --noconfirm \
    falcond \
    falcond-gui

info "Füge User zur falcond-Gruppe hinzu..."
sudo usermod -aG falcond "$USER"

info "Aktiviere falcond..."
sudo systemctl enable --now falcond.service

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  Setup complete! Please reboot your system.${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""

