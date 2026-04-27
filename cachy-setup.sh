#!/bin/bash
# =============================================================================
# CachyOS Post-Install Setup — GNOME 50
# Voraussetzung: CachyOS mit GNOME + Nvidia installiert
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

[[ $EUID -eq 0 ]] && error "Nicht als root ausführen."

# =============================================================================
# System update
# =============================================================================
info "System aktualisieren..."
sudo pacman -Syu --noconfirm

# =============================================================================
# Base packages
# =============================================================================
info "Base-Pakete installieren..."
sudo pacman -S --noconfirm \
    fastfetch \
    nano \
    xdg-utils \
    xdg-user-dirs \
    power-profiles-daemon \
    fish \
    kitty \
    starship \
    firefox \
    hunspell-de \
    hunspell-en_us \
    steam \
    protontricks \
    lact

# =============================================================================
# Services
# =============================================================================
info "Services aktivieren..."
sudo systemctl enable --now power-profiles-daemon
sudo systemctl enable --now lactd

# =============================================================================
# xdg-user-dirs
# =============================================================================
info "User-Verzeichnisse anlegen..."
xdg-user-dirs-update

# =============================================================================
# Fish shell
# =============================================================================
info "Fish als Standard-Shell setzen..."
chsh -s /usr/bin/fish

info "Fish config schreiben..."
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
info "Starship config schreiben..."
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
info "Kitty config schreiben..."
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf <<'EOF'
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
EOF

# =============================================================================
# Fonts & Codecs
# =============================================================================
info "Fonts, Emoji und Codecs installieren..."
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
# AUR packages
# =============================================================================
info "AUR-Pakete installieren..."
paru -S --noconfirm \
    heroic-games-launcher-bin \
    protonplus \
    faugus-launcher

# =============================================================================
# Environment: gaming.conf
# =============================================================================
info "gaming.conf schreiben..."
sudo mkdir -p /etc/environment.d
sudo tee /etc/environment.d/gaming.conf > /dev/null <<'EOF'
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
PROTON_USE_NTSYNC=1

### NTSYNC
WINEFSYNC=0
WINEESYNC=0

### DLSS SR
DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE=on
DXVK_NVAPI_DRS_NGX_DLSS_SR_MODE=custom
DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_SCALING_RATIO=50
DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest

### DLSS RR
DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE=on
DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest

### Frame Generation (Dynamic MFG)
DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE=on
DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest
DXVK_NVAPI_DRS_NGX_DLSSG_MODE=dynamic
DXVK_NVAPI_DRS_NGX_DLSSG_DYNAMIC_TARGET_FRAME_RATE=240
DXVK_NVAPI_DRS_NGX_DLSSG_DYNAMIC_MULTI_FRAME_COUNT_MAX=5

### Frame Rate Cap
DXVK_FRAME_RATE=237
VKD3D_FRAME_RATE=237

### HDR
DXVK_HDR=1
PROTON_ENABLE_HDR=1
ENABLE_HDR_WSI=1
EOF

# =============================================================================
# Environment: nvidia.conf
# =============================================================================
info "nvidia.conf schreiben..."
sudo tee /etc/environment.d/nvidia.conf > /dev/null <<'EOF'
LIBVA_DRIVER_NAME=nvidia
NVD_BACKEND=direct
MOZ_DISABLE_RDD_SANDBOX=1
EOF

# =============================================================================
# sysctl
# =============================================================================
info "sysctl vm.max_map_count setzen..."
sudo tee /etc/sysctl.d/99-gaming.conf > /dev/null <<EOF
vm.max_map_count=2147483642
EOF
sudo sysctl --system > /dev/null

# =============================================================================
# Nautilus Vorlagen
# =============================================================================
info "Nautilus-Vorlagen anlegen..."
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
# Firefox policies.json
# =============================================================================
info "Firefox via policies.json konfigurieren..."
sudo mkdir -p /usr/lib/firefox/distribution
sudo tee /usr/lib/firefox/distribution/policies.json > /dev/null <<'EOF'
{
  "policies": {
    "DisableTelemetry": true,
    "Preferences": {
      "media.ffmpeg.vaapi.enabled":                  { "Value": true, "Status": "default" },
      "media.rdd-ffmpeg.enabled":                    { "Value": true, "Status": "default" },
      "media.hardware-video-decoding.force-enabled": { "Value": true, "Status": "default" },
      "widget.dmabuf.force-enabled":                 { "Value": true, "Status": "default" },
      "media.av1.enabled":                           { "Value": true, "Status": "default" },
      "gfx.webrender.all":                           { "Value": true, "Status": "default" }
    }
  }
}
EOF

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  cachy-setup done! Bitte neu starten.      ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
