#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Installing dev distrobox definitions and ujust recipes"

# Distrobox assemble file for the gtk-dev, rust-dev and flutter-dev boxes.
install -Dm644 /ctx/distrobox/dev.ini /usr/share/bazzite-blue/distrobox/dev.ini

# Bazzite's justfile imports this file if it exists.
install -Dm644 /ctx/just/60-custom.just /usr/share/ublue-os/just/60-custom.just
