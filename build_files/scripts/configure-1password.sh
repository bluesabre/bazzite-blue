#!/usr/bin/env sh

set ${SET_X:+-x} -eou pipefail

echo "Enabling 1Password / Vivaldi connection"

mkdir -p /etc/1password/

cat <<EOF >/etc/1password/custom_allowed_browsers
vivaldi-bin
EOF

chmod 755 /etc/1password/custom_allowed_browsers