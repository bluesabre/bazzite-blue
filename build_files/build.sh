#!/usr/bin/env bash

set -ouex pipefail

# Each installer lives in /ctx/scripts. Optional installers are left
# commented out; uncomment one to bake that app into the image.

systemctl enable podman.socket

# Image signature verification (cosign)
/ctx/scripts/configure-signing.sh

# Desktop warning when the booted image gets stale
/ctx/scripts/install-image-age-check.sh

# Fonts
/ctx/scripts/install-fonts.sh

# KDE Plasma defaults (theme, wallpaper, panel layout, app settings)
/ctx/scripts/configure-kde-defaults.sh

# 1Password (stable channel; pass "edge" for the beta channel)
/ctx/scripts/install-1password.sh stable

# Browsers (optional)
# /ctx/scripts/install-brave.sh
# /ctx/scripts/install-vivaldi.sh

# Virtualization
/ctx/scripts/install-virt-manager.sh

# Visual Studio Code
/ctx/scripts/install-vscode.sh

# Insync (optional)
# /ctx/scripts/install-insync.sh

# Utilities
/ctx/scripts/install-utilities.sh
