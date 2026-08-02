#!/usr/bin/env sh

set ${SET_X:+-x} -eou pipefail

echo "Installing Fonts"

dnf5 install -y mscore-fonts-all \
    xorg-x11-font-utils \
    cabextract \
    fontconfig \
    rsms-inter-fonts \
    binutils \
    zstd

rpm -i --nodigest https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Install Ubuntu fonts directly from Canonical's Debian package instead of
# relying on the unofficial atim/ubuntu-fonts copr. fonts-ubuntu already
# bundles Ubuntu Mono and the newer Ubuntu Sans / Ubuntu Sans Mono variable
# fonts, so no other source package is needed.
UBUNTU_FONTS_DEB="fonts-ubuntu_0.869+git20240321-0ubuntu2_all.deb"
UBUNTU_FONTS_URL="https://archive.ubuntu.com/ubuntu/pool/main/f/fonts-ubuntu/${UBUNTU_FONTS_DEB}"
UBUNTU_FONTS_DIR="/usr/share/fonts/ubuntu"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

mkdir -p "$UBUNTU_FONTS_DIR"

curl -fLo "$workdir/$UBUNTU_FONTS_DEB" "$UBUNTU_FONTS_URL"
(cd "$workdir" && ar x "$UBUNTU_FONTS_DEB" data.tar.zst)
tar --zstd -xf "$workdir/data.tar.zst" -C "$workdir"

find "$workdir/usr/share/fonts" -name '*.ttf' -exec cp -t "$UBUNTU_FONTS_DIR" {} +
chmod 644 "$UBUNTU_FONTS_DIR"/*.ttf

fc-cache -f "$UBUNTU_FONTS_DIR"
