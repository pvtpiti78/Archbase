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
    ly

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
sudo systemctl enable ly

# =============================================================================
# Niri config — spawn Noctalia at startup
# =============================================================================
info "Writing niri config..."
mkdir -p ~/.config/niri
cat > ~/.config/niri/config.kdl <<'EOF'
// Niri config — minimal base
// Noctalia handles the shell, bar, wallpaper and lock screen

// Start Noctalia shell
spawn-at-startup "noctalia-qs" "-c" "noctalia-shell"

input {
    keyboard {
        xkb {
            layout "de"
        }
    }
    touchpad {
        tap
        natural-scroll
    }
}

output "eDP-1" {
    scale 1.0
}

prefer-no-csd

screenshot-path "~/Bilder/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png"
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
