#!/bin/bash
# =============================================================================
# Minimal Niri + Noctalia Setup
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
# Niri + dependencies
# =============================================================================
info "Installing Niri and dependencies..."
sudo pacman -S --noconfirm \
    niri \
    xwayland-satellite \
    xdg-desktop-portal-gnome \
    pipewire \
    wireplumber \
    ly \
    nautilus \
    file-roller \
    gnome-text-editor \
    gnome-keyring \
    gvfs \
    nwg-look \
    adw-gtk-theme \
    qt6ct \
    qt5ct

# =============================================================================
# AUR packages
# =============================================================================
info "Installing Noctalia Shell..."
# noctalia-shell pulls noctalia-qs automatically
# noctalia-qs conflicts with quickshell/quickshell-git
paru -S --noconfirm noctalia-shell

# =============================================================================
# Enable ly
# =============================================================================
info "Enabling ly display manager..."
sudo systemctl enable ly@tty1

# =============================================================================
# Niri config — spawn Noctalia at startup
# =============================================================================
info "Writing niri config..."
mkdir -p ~/.config/niri
cat > ~/.config/niri/config.kdl <<'EOF'
// =============================================================================
// Niri config — Archbase
// =============================================================================

prefer-no-csd

screenshot-path "~/Bilder/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png"

// =============================================================================
// Noctalia Shell
// =============================================================================
spawn-at-startup "noctalia-qs" "-c" "noctalia-shell"

// =============================================================================
// Environment
// =============================================================================
environment {
    QT_QPA_PLATFORMTHEME "qt6ct"
}

// =============================================================================
// Input
// =============================================================================
input {
    keyboard {
        xkb {
            layout "de"
        }
        repeat-delay 200
        repeat-rate 35
    }
    mouse {
        accel-speed 0.0
        accel-profile "flat"
    }
}

// =============================================================================
// Keybindings
// =============================================================================
binds {
    // Applications
    Mod+Return { spawn "kitty"; }
    Mod+B { spawn "firefox"; }
    Mod+E { spawn "nautilus"; }

    // Noctalia IPC
    Mod+D { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
    Mod+L { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "lockScreen" "lock"; }
    Mod+Shift+Q { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "sessionMenu" "toggle"; }
    Mod+C { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "controlCenter" "toggle"; }

    // Window management
    Mod+Q { close-window; }
    Mod+F { maximize-column; }
    Mod+Shift+F { fullscreen-window; }
    Mod+Space { toggle-window-floating; }

    // Focus
    Mod+Left { focus-column-left; }
    Mod+Right { focus-column-right; }
    Mod+Up { focus-window-up; }
    Mod+Down { focus-window-down; }
    Mod+H { focus-column-left; }
    Mod+L { focus-column-right; }
    Mod+K { focus-window-up; }
    Mod+J { focus-window-down; }

    // Move windows
    Mod+Shift+Left { move-column-left; }
    Mod+Shift+Right { move-column-right; }
    Mod+Shift+Up { move-window-up; }
    Mod+Shift+Down { move-window-down; }
    Mod+Shift+H { move-column-left; }
    Mod+Shift+L { move-column-right; }
    Mod+Shift+K { move-window-up; }
    Mod+Shift+J { move-window-down; }

    // Workspaces
    Mod+1 { focus-workspace 1; }
    Mod+2 { focus-workspace 2; }
    Mod+3 { focus-workspace 3; }
    Mod+4 { focus-workspace 4; }
    Mod+5 { focus-workspace 5; }
    Mod+Shift+1 { move-column-to-workspace 1; }
    Mod+Shift+2 { move-column-to-workspace 2; }
    Mod+Shift+3 { move-column-to-workspace 3; }
    Mod+Shift+4 { move-column-to-workspace 4; }
    Mod+Shift+5 { move-column-to-workspace 5; }
    Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
    Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }

    // Screenshots
    Mod+S { screenshot; }
    Ctrl+Print { screenshot-screen; }
    Alt+Print { screenshot-window; }

    // Media keys
    XF86AudioRaiseVolume allow-when-locked=true { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "volume" "increase"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "volume" "decrease"; }
    XF86AudioMute allow-when-locked=true { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "volume" "muteOutput"; }
    XF86AudioNext allow-when-locked=true { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "media" "next"; }
    XF86AudioPrev allow-when-locked=true { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "media" "previous"; }
    XF86AudioPlay allow-when-locked=true { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "media" "playPause"; }

    // Hotkey overlay
    Mod+Shift+Slash { show-hotkey-overlay; }
    Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
}
EOF

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  Niri setup complete! Please reboot.       ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
warn "After reboot: select Niri from the ly session menu."
warn "Adjust monitor output name in ~/.config/niri/config.kdl if needed."
