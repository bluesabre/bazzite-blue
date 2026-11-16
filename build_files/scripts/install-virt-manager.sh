#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Installing virt-manager"

# Bazzite sets install_weak_deps=False, so virt-manager's recommended
# libvirt daemon and QEMU packages must be requested explicitly.
dnf5 install -y \
    virt-install \
    virt-manager \
    virt-viewer \
    libvirt-daemon-kvm \
    libvirt-daemon-config-network \
    swtpm

# Enable the modular libvirt daemons (socket-activated, Fedora default).
for drv in qemu network nodedev nwfilter secret storage interface; do
    systemctl enable "virt${drv}d.socket" "virt${drv}d-ro.socket" "virt${drv}d-admin.socket"
done
systemctl enable virtproxyd.socket virtproxyd-ro.socket virtproxyd-admin.socket
systemctl enable virtlogd.socket virtlockd.socket
