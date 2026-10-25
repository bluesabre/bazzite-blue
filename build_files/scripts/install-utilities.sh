#!/usr/bin/env sh

set ${SET_X:+-x} -eou pipefail

echo "Installing Utilities"

dnf5 install -y optipng \
    flatpak-builder \
    yakuake
