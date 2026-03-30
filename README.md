# Archbase

A minimal, opinionated Arch Linux post-install script that sets up a complete gaming-ready base system — before any desktop environment is installed.

## Philosophy

- No bloat, no hand-holding
- Rolling release, always current
- Nvidia-first (RTX 5000 series / open kernel modules)
- Gaming-optimized out of the box
- DE-agnostic — install whatever you want on top

## What it does

### System
- Enables multilib repository
- Optimizes `pacman.conf` (parallel downloads, color, ILoveCandy)
- Configures and runs `reflector` for fast mirrors (DE/FR/NL)
- Enables `paccache.timer` for automatic cache cleanup
- Enables `NetworkManager`
- Enables `power-profiles-daemon`

### Shell & Terminal
- Installs `fish` and sets it as default shell
- Installs `kitty` terminal

### Fonts & Codecs
- Noto fonts (including CJK and Emoji)
- JetBrains Mono Nerd Font
- Full GStreamer stack + ffmpeg
- libva for hardware video decode

### Nvidia
- `nvidia-open-dkms` + `nvidia-utils` + `lib32-nvidia-utils`
- `libva-nvidia-driver`
- `nvidia-persistenced` enabled at boot

### AUR (via paru)
- `paru` built from source
- `yay` symlinked to `paru`
- Steam
- Google Chrome
- Heroic Games Launcher (`heroic-games-launcher-bin`)
- ProtonPlus
- ProtonTricks
- Faugus Launcher
- LACT (GPU control, `lactd` enabled)

### Config files
- `~/.config/environment.d/gaming.conf` — Proton/DLSS/MFG/HDR/NTSYNC/VRR settings
- `~/.config/environment.d/nvidia.conf` — Nvidia Wayland/Vulkan/Electron settings
- `~/.config/chrome-flags.conf` — Chrome Wayland/GPU flags

## Usage

```bash
# After a fresh archinstall (minimal profile, no DE):
sudo pacman -S git base-devel
git clone https://github.com/pvtpiti78/Archbase.git
cd Archbase
chmod +x arch-setup.sh
./arch-setup.sh
```

After the script completes, install your DE of choice and reboot.

## Requirements

- Fresh Arch Linux install (archinstall minimal)
- Nvidia GPU (RTX 900 series or newer, open kernel module compatible)
- Internet connection (wired recommended during setup)
- User with sudo privileges

## Notes

- `linux-headers` is installed automatically for DKMS
- multilib is enabled automatically for 32-bit Steam/Wine support
- The script will not run as root
- After reboot, DKMS builds the Nvidia module automatically
