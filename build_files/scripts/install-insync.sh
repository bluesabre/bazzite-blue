#!/usr/bin/env sh

set ${SET_X:+-x} -eou pipefail

echo "Installing Insync (Fedora 43)"

# Setup repo
cat <<EOF >/etc/yum.repos.d/insync.repo
[insync]
name=insync repo
baseurl=http://yum.insync.io/fedora/43/
gpgcheck=1
gpgkey=https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key
enabled=1
metadata_expire=120m
EOF

# Import signing key
rpm --import https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key

# Now let's install the packages.
dnf5 install -y insync

# Disable the yum repo (updates are baked into new images)
sed -i "s@enabled=1@enabled=0@" /etc/yum.repos.d/insync.repo
