#!/usr/bin/env bash

# Credit to: https://github.com/benhoman/ublue/blob/9f079aa2ece3223f16aef8e6a635c73111323ab4/build_files/scripts/install-1password.sh
# The file below is benhoman's credit.

# Thanks to bri for the inspiration! My script is mostly based on this example:
# https://github.com/briorg/bluefin/blob/c62c30a04d42fd959ea770722c6b51216b4ec45b/scripts/1password.sh

# Usage: install-1password.sh [stable|edge]

set ${SET_X:+-x} -eou pipefail

CHANNEL="${1:-stable}"
case "$CHANNEL" in
stable)
    REPO_ID="1password"
    REPO_NAME="1Password Stable Channel"
    ;;
edge)
    REPO_ID="1password-edge"
    REPO_NAME="1Password Edge Channel"
    ;;
*)
    echo "Unknown 1Password channel: $CHANNEL (expected stable or edge)" >&2
    exit 1
    ;;
esac
REPO_FILE="/etc/yum.repos.d/${REPO_ID}.repo"

echo "Installing 1Password (${CHANNEL})"

# On libostree systems, /opt is a symlink to /var/opt,
# which actually only exists on the live system. /var is
# a separate mutable, stateful FS that's overlaid onto
# the ostree rootfs. Therefore we need to install it into
# /usr/lib/1Password instead, and dynamically create a
# symbolic link /opt/1Password => /usr/lib/1Password upon
# boot.

# Prepare staging directory
mkdir -p /var/opt

# Setup repo
cat <<EOF >"$REPO_FILE"
[${REPO_ID}]
name=${REPO_NAME}
baseurl=https://downloads.1password.com/linux/rpm/${CHANNEL}/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF

# Import signing key
rpm --import https://downloads.1password.com/linux/keys/1password.asc

# Prepare 1Password groups
# The RPM's after-install.sh creates groups that can conflict with the
# default user's GID, so pre-create them with fixed GIDs (> 1000, well
# clear of the sequential user GIDs Fedora hands out from 1000).
GID_ONEPASSWORD="1790"
GID_ONEPASSWORDCLI="1791"
GID_ONEPASSWORDMCP="1792" # setgid group for the 1password-mcp server binary
groupadd -g "${GID_ONEPASSWORD}" onepassword
groupadd -g "${GID_ONEPASSWORDCLI}" onepassword-cli
groupadd -g "${GID_ONEPASSWORDMCP}" onepassword-mcp

# The groupadd above only lands in this image's /etc/group, which is not
# merged into systems that are already deployed. Ship a sysusers.d entry so
# systemd-sysusers creates the same groups (same GIDs as the setgid files
# below) on every boot where they are missing.
cat >/usr/lib/sysusers.d/onepassword.conf <<EOF
g onepassword     ${GID_ONEPASSWORD}
g onepassword-cli ${GID_ONEPASSWORDCLI}
g onepassword-mcp ${GID_ONEPASSWORDMCP}
EOF

# Now let's install the packages.
dnf5 install -y 1password 1password-cli

# This places the 1Password contents in an image safe location
mv /var/opt/1Password /usr/lib/1Password

# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/onepassword.conf <<EOF
L  /opt/1Password  -  -  -  -  /usr/lib/1Password
EOF

# Enable connection with Vivaldi browser
mkdir -p /etc/1password/

cat <<EOF >/etc/1password/custom_allowed_browsers
vivaldi-bin
EOF

chmod 644 /etc/1password/custom_allowed_browsers

# Disable the yum repo (updates are baked into new images)
sed -i "s@enabled=1@enabled=0@" "$REPO_FILE"
