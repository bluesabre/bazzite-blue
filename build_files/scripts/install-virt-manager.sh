#!/usr/bin/env sh

set ${SET_X:+-x} -eou pipefail

echo "Installing virt-manager"

# Now let's install the packages.
dnf5 install -y virt-install virt-manager virt-viewer
