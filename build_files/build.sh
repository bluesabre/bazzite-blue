#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# dnf5 install -y 1password 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

systemctl enable podman.socket

# Install Fonts
/ctx/scripts/install-fonts.sh

# Install 1password
/ctx/scripts/install-1password.sh

# Install Vivaldi
/ctx/scripts/install-vivaldi.sh

# Install virt-manager
/ctx/scripts/install-virt-manager.sh

# Install code
/ctx/scripts/install-vscode.sh

# Install Insync
/ctx/scripts/install-insync.sh

# Install utilities
/ctx/scripts/install-utilities.sh
