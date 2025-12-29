#!/usr/bin/env sh

set ${SET_X:+-x} -eou pipefail

echo "Installing Vivaldi"

# Setup repo
cat <<EOF >/etc/yum.repos.d/vivaldi.repo
[vivaldi]
name=vivaldi
baseurl=https://repo.vivaldi.com/archive/rpm/x86_64
enabled=1
gpgcheck=1
gpgkey=https://repo.vivaldi.com/archive/linux_signing_key.pub
EOF

# Import signing key
rpm --import https://repo.vivaldi.com/archive/linux_signing_key.pub

# Now let's install the packages.
dnf5 install -y vivaldi-stable

# Disable the yum repo (updates are baked into new images)
sed -i "s@enabled=1@enabled=0@" /etc/yum.repos.d/vivaldi.repo
