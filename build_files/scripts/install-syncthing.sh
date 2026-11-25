#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Installing Syncthing"

# Ships the syncthing.service user unit. It stays disabled here; each user
# opts in with `ujust setup-syncthing`, which also enables lingering so it
# starts at boot without a login.
dnf5 install -y syncthing
