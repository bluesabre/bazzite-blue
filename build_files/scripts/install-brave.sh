#!/usr/bin/env sh

set ${SET_X:+-x} -eou pipefail

echo "Installing Brave Browser"

# Setup repo
cat << EOF > /etc/yum.repos.d/brave-browser.repo
[brave-browser]
name=Brave Browser
enabled=1
autorefresh=1
baseurl=https://brave-browser-rpm-release.s3.brave.com/x86_64
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
EOF

# Import signing key
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

# Now let's install the packages.
dnf5 install -y brave-browser

# This places the Brave contents in an image safe location
mv /var/opt/brave.com /usr/lib/brave.com # move this over here

# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/brave-browser.conf <<EOF
L  /opt/brave.com -  -  -  -  /usr/lib/brave.com
EOF

# Disable the yum repo (updates are baked into new images)
sed -i "s@enabled=1@enabled=0@" /etc/yum.repos.d/brave-browser.repo
