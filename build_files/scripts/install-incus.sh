#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Installing Incus"

# Bazzite sets install_weak_deps=False. QEMU, OVMF, swtpm and virtiofsd
# for Incus VMs come from install-virt-manager.sh and the base image.
dnf5 install -y \
    incus \
    incus-agent \
    lxcfs

# Socket-activated daemon; incus-startup restarts autostart instances at boot.
systemctl enable incus.socket incus-startup.service lxcfs.service

# Per-user setup (group membership, subuid/subgid, init, firewalld) happens
# at runtime via `ujust setup-incus`, since bootc keeps locally edited /etc files.
