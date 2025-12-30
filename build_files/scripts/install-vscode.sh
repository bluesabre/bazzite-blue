#!/usr/bin/env sh

set ${SET_X:+-x} -eou pipefail

echo "Installing VS Code"

# Setup repo
cat <<EOF >/etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Import signing key
rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Now let's install the packages.
dnf5 install -y code

# Disable the yum repo (updates are baked into new images)
sed -i "s@enabled=1@enabled=0@" /etc/yum.repos.d/vscode.repo
