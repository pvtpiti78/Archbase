#!/bin/bash
# =============================================================================
# Archbase Performance Setup — Full Meme Mode 🚀
# Run after arch-setup.sh
# Includes: CachyOS repo, linux-cachyos-bore, scx-tools, falcond, sysctl tweaks
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
# CachyOS Repository (x86-64-v3 — compatible with stock Arch pacman)
# Note: skipping [cachyos] itself to avoid custom pacman fork
# =============================================================================
info "Adding CachyOS repository..."
sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key F3B607488DB35A47
sudo pacman -U --noconfirm \
    'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
    'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-27-1-any.pkg.tar.zst' \
    'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-27-1-any.pkg.tar.zst' \
    'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v4-mirrorlist-27-1-any.pkg.tar.zst'

info "Configuring CachyOS repos in pacman.conf..."

# Architecture = auto (good practice)
sudo sed -i 's/^Architecture = .*/Architecture = auto/' /etc/pacman.conf
if ! grep -q "^Architecture" /etc/pacman.conf; then
    sudo sed -i '/^\[options\]/a Architecture = auto' /etc/pacman.conf
fi

# Remove Chaotic-AUR if present (conflicts with CachyOS)
if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    warn "Removing Chaotic-AUR from pacman.conf..."
    sudo sed -i '/^\[chaotic-aur\]/,/^$/d' /etc/pacman.conf
fi

# Add CachyOS v3 repos above [core]
if ! grep -q "\[cachyos-v3\]" /etc/pacman.conf; then
    sudo sed -i '/^\[core\]/i [cachyos-v3]\nInclude = /etc/pacman.d/cachyos-v3-mirrorlist\n[cachyos-core-v3]\nInclude = /etc/pacman.d/cachyos-v3-mirrorlist\n[cachyos-extra-v3]\nInclude = /etc/pacman.d/cachyos-v3-mirrorlist\n' /etc/pacman.conf
else
    warn "CachyOS repos already in pacman.conf — skipping"
fi

sudo pacman -Sy --noconfirm

# =============================================================================
# linux-cachyos-bore (BORE scheduler, CachyOS prebuilt binary — no compile!)
# =============================================================================
info "Installing linux-cachyos-bore kernel..."
sudo pacman -S --noconfirm linux-cachyos-bore linux-cachyos-bore-headers

# =============================================================================
# scx-tools (sched_ext userspace tools)
# =============================================================================
info "Installing scx-tools and scx-scheds..."
sudo pacman -S --noconfirm scx-tools scx-scheds

info "Configuring scx_loader with scx_cosmos as default..."
sudo tee /etc/scx_loader.toml > /dev/null <<'EOF'
# scx_loader configuration
default_sched = "scx_cosmos"
default_mode = "Auto"
EOF

info "Enabling scx_loader service..."
sudo systemctl enable --now scx_loader

# =============================================================================
# falcond + falcond-gui + falcond-profiles
# =============================================================================
info "Installing falcond..."
paru -S --noconfirm falcond falcond-profiles

info "Installing falcond-gui..."
paru -S --noconfirm falcond-gui || warn "falcond-gui build failed — known AUR issue, skipping"

info "Adding user to falcond group..."
sudo usermod -aG falcond "$USER"

info "Configuring falcond..."
sudo mkdir -p /etc/falcond
sudo tee /etc/falcond/config.toml > /dev/null <<'EOF'
# falcond global config
enable_performance_mode = true
scx_sched = "cosmos"
scx_sched_props = "gaming"
vcache_mode = "cache"
profile_mode = "none"
poll_interval_ms = 9000
EOF

info "Enabling falcond..."
sudo systemctl enable --now falcond

# =============================================================================
# sysctl tweaks — bis zur Kotzgrenze 🤢
# =============================================================================
info "Writing performance sysctl tweaks..."
sudo tee /etc/sysctl.d/99-performance.conf > /dev/null <<'EOF'
# =============================================================================
# Archbase Performance Tweaks
# Inspired by CachyOS-Settings — bis zur Kotzgrenze Edition
# =============================================================================

# --- Memory Management ---
# Prefer to keep app data in RAM over file cache
vm.swappiness = 10
# Less aggressive VFS cache reclaim
vm.vfs_cache_pressure = 50
# Disable swap readahead (zram doesn't need it)
vm.page-cluster = 0
# Dirty page writeback tuning (reduce I/O latency spikes)
vm.dirty_bytes = 268435456
vm.dirty_background_bytes = 67108864
vm.dirty_writeback_centisecs = 1500
# Max map count (Steam/Proton requirement)
vm.max_map_count = 2147483642

# --- CPU & Scheduler ---
# Disable NMI watchdog (better performance, lower power)
kernel.nmi_watchdog = 0
# Allow unprivileged user namespaces (needed for sandboxing)
kernel.unprivileged_userns_clone = 1
# Hide kernel pointers from unprivileged users
kernel.kptr_restrict = 2
# Faster context switches for gaming
kernel.sched_cfs_bandwidth_slice_us = 3000
# Reduce scheduler migration cost
kernel.sched_migration_cost_ns = 250000
# Boost interactive tasks
kernel.sched_autogroup_enabled = 1

# --- Network ---
# Larger network buffers
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.core.netdev_max_backlog = 16384
# BBR congestion control
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
# Fast TCP recycling
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_tw_reuse = 1
# Reduce TCP keepalive time
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6

# --- Security (minimal impact) ---
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1

# --- File system ---
# More inotify watches (needed for IDEs, Steam etc.)
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 1024
EOF

sudo sysctl --system

# =============================================================================
# udev rules — NVMe I/O scheduler + NVIDIA tweaks
# =============================================================================
info "Writing udev rules..."
sudo tee /etc/udev/rules.d/60-io-scheduler.rules > /dev/null <<'EOF'
# NVMe — no scheduler needed (hardware queue)
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# SATA SSD — mq-deadline
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# HDD — bfq
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF

sudo tee /etc/udev/rules.d/61-nvidia-performance.rules > /dev/null <<'EOF'
# NVIDIA — enable PAT for CPU performance
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", RUN+="/usr/bin/bash -c 'echo 1 > /sys/module/nvidia/parameters/NVreg_UsePageAttributeTable'"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger

# =============================================================================
# modprobe — disable watchdog, audio power saving
# =============================================================================
info "Writing modprobe tweaks..."
sudo tee /etc/modprobe.d/performance.conf > /dev/null <<'EOF'
# Disable audio power saving (reduces latency)
options snd-hda-intel power_save=0 power_save_controller=N

# Disable watchdog timers
blacklist iTCO_wdt
blacklist sp5100_tco
EOF

# =============================================================================
# systemd tweaks
# =============================================================================
info "Configuring systemd for faster boot/shutdown..."
sudo mkdir -p /etc/systemd/system.conf.d
sudo tee /etc/systemd/system.conf.d/performance.conf > /dev/null <<'EOF'
[Manager]
DefaultTimeoutStartSec=15s
DefaultTimeoutStopSec=10s
EOF

sudo mkdir -p /etc/systemd/journald.conf.d
sudo tee /etc/systemd/journald.conf.d/performance.conf > /dev/null <<'EOF'
[Journal]
SystemMaxUse=50M
EOF

# =============================================================================
# zram tuning
# =============================================================================
info "Optimizing zram..."
sudo mkdir -p /etc/systemd/zram-generator.conf.d
sudo tee /etc/systemd/zram-generator.conf.d/performance.conf > /dev/null <<'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  Performance setup complete!               ${NC}"
echo -e "${GREEN}  Reboot to load linux-tkg-bore kernel.     ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
warn "After reboot: select linux-tkg-bore in your bootloader!"
warn "scx_cosmos will start automatically via scx.service"
warn "falcond will auto-optimize games on launch"
