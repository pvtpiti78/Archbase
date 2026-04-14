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

For Hyprland, extract the config package first:

```bash
tar -xzf hyprland-setup.tar.gz
chmod +x hyprland-setup.sh
./hyprland-setup.sh
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
- Installs `kitty` terminal with Tokyo Night theme
- Installs `starship` prompt with Tokyo Night theme
- Installs `fastfetch` with Arch logo config

**Fonts & Codecs**
- Noto fonts (including CJK and Emoji)
- JetBrains Mono Nerd Font
- Full GStreamer stack + ffmpeg
- libva for hardware video decode

**Nvidia**
- `nvidia-open-dkms` + `nvidia-utils` + `lib32-nvidia-utils`
- `libva-nvidia-driver`
- `nvidia-persistenced` enabled at boot

**Gaming**
- Steam, Heroic Games Launcher, ProtonPlus, Protontricks, Faugus Launcher
- Firefox with German dictionary (`hunspell-de`)
- LACT (GPU control, `lactd` enabled)
- Shelly GUI package manager (`shelly-bin`)

**AUR (via paru)**
- `paru` built from source, `yay` symlinked
- BottomUp, NewsOnUpgrade, CleanAfter, SudoLoop enabled

**Environment configs**
- `~/.config/environment.d/gaming.conf` — Proton / DLSS SR+RR / Dynamic MFG / HDR / NTSYNC / VRR
- `~/.config/environment.d/nvidia.conf` — Nvidia Wayland / Vulkan / Electron / Firefox HW decode
- `~/.config/fish/config.fish` — Starship prompt, Fastfetch on start, aliases (update, hardclean, ...)
- `~/.config/starship.toml` — Tokyo Night prompt theme
- `~/.config/kitty/kitty.conf` — Tokyo Night theme, JetBrains Mono Nerd, Fish shell
- `~/.config/fastfetch/config.jsonc` — Arch logo, system info

### install-de.sh
Interactive DE installer. Run after `arch-setup.sh`.
Choose between KDE Plasma, GNOME, Hyprland, Niri + Noctalia, or COSMIC Desktop.

### kde-setup.sh
Minimal KDE Plasma setup. Installs only what's needed — no bloat.
- plasma-desktop, plasma-nm, plasma-pa, kscreen, plasmalogin
- Dolphin, Kate, Ark, Breeze GTK

### gnome-setup.sh
Minimal GNOME 50 setup.
- gnome-shell, gnome-control-center, gdm
- Nautilus, GNOME Text Editor, File Roller, Resources, Loupe
- xdg-desktop-portal-gnome, gnome-keyring, gvfs
- extension-manager

### cosmic-setup.sh
Minimal COSMIC Desktop 1.0.9 setup with cosmic-greeter.
- Full COSMIC without cosmic-store
- cosmic-session, compositor, panel, applets, launcher
- cosmic-files, cosmic-text-editor, cosmic-terminal
- cosmic-greeter as display manager

### hyprland-setup.sh
Hyprland with custom Quickshell bar. Requires `hyprland-setup.tar.gz`.
- hyprland, hyprpaper, hypridle, hyprlock, hyprpolkitagent
- quickshell-git (AUR) with custom Tokyo Night bar
- Workspace pills, centered clock, volume widget, system tray, power menu
- swaync for notifications, rofi-wayland as launcher
- Dolphin, Kate, Ark, breeze-gtk
- ly display manager

### niri-setup.sh
Minimal Niri + Noctalia setup with ly display manager.
- niri (scrollable-tiling Wayland compositor)
- xwayland-satellite for X11 app support
- noctalia-shell (AUR) — Quickshell-based desktop shell
- Nautilus, File Roller, GNOME Text Editor
- ly display manager, qt6ct, nwg-look, adw-gtk-theme

### performance-setup.sh
Optional performance stack. Run after arch-setup.sh.
- linux-zen kernel (gaming-optimized, official Arch repo)
- scx-tools + scx-scheds — sched_ext with scx_cosmos via scx_loader
- falcond + falcond-profiles — automatic per-game optimization
- falcond-gui (AUR)
- sysctl tweaks — memory, CPU, network, BBR
- udev rules — optimal I/O schedulers per device type
- modprobe tweaks — disable audio power saving, watchdogs
- systemd tuning — faster boot/shutdown
- zram optimization with zstd

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
- Hyprland requires wallpaper at `~/Bilder/wallpaper.jpg` before first start
