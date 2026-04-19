#!/bin/bash
# =============================================================================
# Archbase Performance Setup
# Run after arch-setup.sh
# Includes: linux-zen, scx-tools, falcond, sysctl tweaks
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
# linux-zen (gaming-optimized, official Arch repo — no compile, no hassle)
# =============================================================================
info "Installing linux-zen kernel..."
sudo pacman -S --noconfirm linux-zen linux-zen-headers

info "Creating systemd-boot entry for linux-zen..."
PARTUUID=$(findmnt -no PARTUUID /)
EXISTING_OPTS=$(grep "^options" /boot/loader/entries/*.conf 2>/dev/null | head -1 | cut -d' ' -f2-)
if [ -z "$EXISTING_OPTS" ]; then
    EXISTING_OPTS="root=PARTUUID=${PARTUUID} rw rootfstype=xfs"
fi

if [ ! -f /boot/loader/entries/arch-linux-zen.conf ]; then
    printf "title   Arch Linux (linux-zen)\nlinux   /vmlinuz-linux-zen\ninitrd  /initramfs-linux-zen.img\noptions %s\n" "$EXISTING_OPTS" | sudo tee /boot/loader/entries/arch-linux-zen.conf > /dev/null
    info "Bootloader entry created for linux-zen"
else
    warn "Bootloader entry already exists — skipping"
fi

# =============================================================================
# scx-tools + scx-scheds (sched_ext userspace tools)
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
paru -S --noconfirm falcond-gui || warn "falcond-gui build failed — skipping"

info "Adding user to falcond group..."
sudo groupadd --system falcond 2>/dev/null || true
sudo mkdir -p /usr/share/falcond/profiles/user
sudo chown :falcond /usr/share/falcond/profiles/user
sudo chmod 2775 /usr/share/falcond/profiles/user
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
sudo systemctl enable falcond
warn "Falcond enabled — log out and back in for group permissions to take effect, then: sudo systemctl start falcond"

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
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.page-cluster = 0
vm.dirty_bytes = 268435456
vm.dirty_background_bytes = 67108864
vm.dirty_writeback_centisecs = 1500
vm.max_map_count = 2147483642

# --- CPU & Scheduler ---
kernel.nmi_watchdog = 0
kernel.unprivileged_userns_clone = 1
kernel.kptr_restrict = 2
kernel.sched_migration_cost_ns = 250000
kernel.sched_autogroup_enabled = 1

# --- Network ---
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.core.netdev_max_backlog = 16384
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6

# --- Security ---
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1

# --- Filesystem ---
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 1024
EOF

sudo sysctl --system

# =============================================================================
# udev rules — I/O scheduler
# =============================================================================
info "Writing udev rules..."
sudo tee /etc/udev/rules.d/60-io-scheduler.rules > /dev/null <<'EOF'
# NVMe — no scheduler needed
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# SATA SSD — mq-deadline
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# HDD — bfq
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger

# =============================================================================
# modprobe tweaks
# =============================================================================
info "Writing modprobe tweaks..."
sudo tee /etc/modprobe.d/performance.conf > /dev/null <<'EOF'
# Disable audio power saving
options snd-hda-intel power_save=0 power_save_controller=N

# Disable watchdog timers
blacklist iTCO_wdt
blacklist sp5100_tco
EOF

# =============================================================================
# systemd tweaks
# =============================================================================
info "Configuring systemd..."
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
echo -e "${GREEN}  Reboot to load linux-zen kernel.          ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
warn "After reboot: select linux-zen in your bootloader!"
warn "scx_cosmos starts automatically via scx_loader"
warn "falcond auto-optimizes games on launch"
warn "Log out and back in for falcond group to take effect"
