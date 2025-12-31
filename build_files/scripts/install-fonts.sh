#!/usr/bin/env sh

set ${SET_X:+-x} -eou pipefail

echo "Installing Fonts"

dnf5 -y copr enable atim/ubuntu-fonts

dnf5 install -y mscore-fonts-all \
    xorg-x11-font-utils \
    cabextract \
    fontconfig \
    rsms-inter-fonts \
    ubuntu-family-fonts

rpm -i --nodigest https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

dnf5 -y copr disable atim/ubuntu-fonts
