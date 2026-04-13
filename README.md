# Archbase

A minimal, opinionated Arch Linux post-install script collection that sets up a complete gaming-ready base system with optional desktop environment installation.

## Philosophy

- No bloat, no hand-holding
- Rolling release, always current
- Nvidia-first (RTX series / open kernel modules)
- Gaming-optimized out of the box
- Every package consciously chosen

## Usage

```bash
# After a fresh archinstall (minimal profile, no DE):
sudo pacman -S git base-devel
git clone https://github.com/pvtpiti78/Archbase.git
cd Archbase
chmod +x arch-setup.sh
./arch-setup.sh
```

After `arch-setup.sh` completes, run the DE installer:

```bash
chmod +x install-de.sh
./install-de.sh
```

## Scripts

### arch-setup.sh
Base system setup. Run this first on every install regardless of DE choice.

**System**
- Optimizes `pacman.conf` (parallel downloads, color, ILoveCandy)
- Optimizes `makepkg.conf` (parallel builds via nproc)
- Configures and runs `reflector` for fast mirrors (DE/FR/NL)
- Enables multilib repository
- Enables `paccache.timer` for automatic cache cleanup
- Enables `NetworkManager`
- Enables `power-profiles-daemon`
- Sets `vm.max_map_count` for gaming (sysctl)

**Shell & Terminal**
- Installs `fish` and sets it as default shell
- Installs `kitty` terminal

**Fonts & Codecs**
- Noto fonts (including CJK and Emoji)
- JetBrains Mono Nerd Font
- Full GStreamer stack + ffmpeg
- libva for hardware video decode

**Nvidia**
- `nvidia-open-dkms` + `nvidia-utils` + `lib32-nvidia-utils`
- `libva-nvidia-driver`
- `nvidia-persistenced` enabled at boot

**AUR (via paru)**
- `paru` built from source, `yay` symlinked
- Steam, Heroic Games Launcher, ProtonPlus, ProtonTricks, Faugus Launcher
- LACT (GPU control, `lactd` enabled)

**Environment configs**
- `~/.config/environment.d/gaming.conf` — Proton / DLSS SR+RR / Dynamic MFG / HDR / NTSYNC / VRR
- `~/.config/environment.d/nvidia.conf` — Nvidia Wayland / Vulkan / Electron / Firefox HW decode
- `~/.config/fish/config.fish` — Starship prompt, Fastfetch on start, aliases
- `~/.config/starship.toml` — Tokyo Night prompt theme
- `~/.config/kitty/kitty.conf` — Tokyo Night theme, JetBrains Mono Nerd, Fish shell
- `~/.config/fastfetch/config.jsonc` — Arch logo, system info

### install-de.sh
Interactive DE installer. Run after `arch-setup.sh`.
Choose between KDE Plasma, GNOME or Hyprland.

### kde-setup.sh
Minimal KDE Plasma setup. Installs only what's needed — no bloat.
- plasma-desktop, plasma-nm, plasma-pa, kscreen, GDM equivalent (plasmalogin)
- Dolphin, Kate, Ark, Breeze GTK

### gnome-setup.sh
Minimal GNOME 50 setup.
- gnome-shell, gnome-control-center, gdm
- Nautilus, GNOME Text Editor, File Roller, Resources, Loupe
- xdg-desktop-portal-gnome, gnome-keyring, gvfs
- extension-manager (AUR)

### hyprland-setup.sh
Minimal Hyprland setup with Quickshell bar.
- Workspace widgets, centered clock, system tray, power menu

### niri-setup.sh
Minimal Niri + Noctalia setup with ly display manager.
- niri (scrollable-tiling Wayland compositor)
- xwayland-satellite for X11 app support
- noctalia-shell (AUR) — pulls noctalia-qs automatically
- ly display manager
- Niri config with Noctalia autostart

## Requirements

- Fresh Arch Linux install (archinstall minimal, no DE)
- Nvidia GPU (open kernel module compatible)
- Internet connection (wired recommended during setup)
- User with sudo privileges
- `git` and `base-devel` installed before running (`sudo pacman -S git base-devel`)

## Notes

- `linux-headers` is installed automatically for DKMS
- multilib is enabled automatically for 32-bit Steam/Wine support
- Scripts will not run as root
- After reboot, DKMS builds the Nvidia module automatically
