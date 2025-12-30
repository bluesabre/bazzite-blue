#!/usr/bin/env sh

set ${SET_X:+-x} -eou pipefail

echo "Installing Fonts"

dnf5 install -y mscore-fonts-all xorg-x11-font-utils cabextract fontconfig

rpm -i --nodigest https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
