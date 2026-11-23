# Bazzite Blue

[![Build container image](https://github.com/bluesabre/bazzite-blue/actions/workflows/build.yml/badge.svg)](https://github.com/bluesabre/bazzite-blue/actions/workflows/build.yml)
[![Lint](https://github.com/bluesabre/bazzite-blue/actions/workflows/lint.yml/badge.svg)](https://github.com/bluesabre/bazzite-blue/actions/workflows/lint.yml)

Bazzite with some [bluesabre](https://github.com/bluesabre)-flavored tweaks. \
_The name is a work-in-progress._

Based on the [ublue-os/image-template](https://github.com/ublue-os/image-template) image template.

## Image Definition

This image is built atop the _Bazzite Nvidia_ (`ghcr.io/ublue-os/bazzite-nvidia:stable`) image. It uses the Nvidia proprietary drivers to support the Nvidia GTX 1080 graphics card, among many others.

The image is rebuilt daily, so it picks up upstream Bazzite updates automatically.

### Added to Bazzite

| Package | File | Credits |
|---------|------|---------|
| 1Password (`1password`, `1password-cli`) _with Vivaldi support_ | [install-1password.sh](/build_files/scripts/install-1password.sh) | [benhoman/ublue](https://github.com/benhoman/ublue/blob/9f079aa2ece3223f16aef8e6a635c73111323ab4/build_files/scripts/install-1password.sh) |
| Inter Font Family (`rsms-inter-fonts`) | [install-fonts.sh](/build_files/scripts/install-fonts.sh) | _N/A_ |
| Microsoft TrueType Core Fonts (`msttcore-fonts`) | [install-fonts.sh](/build_files/scripts/install-fonts.sh) | [kohega/bazzite-khg](https://github.com/kohega/bazzite-khg/blob/500f54715384a66a4c6756a1bc4a8160c82c6c37/build_files/install_packages.sh) |
| Ubuntu Font Family (`fonts-ubuntu`) | [install-fonts.sh](/build_files/scripts/install-fonts.sh) | [rpassmore/my-ublue-os](https://github.com/rpassmore/my-ublue-os/blob/3fe0b5ce2a5a0b1d9c7565cbba2f8eacb9ab6551/build_files/build.sh) |
| Virtual Machine Manager (`virt-manager`, libvirt/QEMU) | [install-virt-manager.sh](/build_files/scripts/install-virt-manager.sh) | [butterflysky/butterfly-ublue](https://github.com/butterflysky/butterfly-ublue/blob/c5f0adaa8fac85fbd0e0f8d53812697c047ffb14/build_files/install-addon-packages.sh) |
| Incus (`incus`, `incus-agent`, `lxcfs`) | [install-incus.sh](/build_files/scripts/install-incus.sh) | _N/A_ |
| Visual Studio Code (`code`) | [install-vscode.sh](/build_files/scripts/install-vscode.sh) | [ublue-os/bluefin](https://github.com/ublue-os/bluefin/blob/10d0ea03a94abff0d736fd3a320e61a9edc7833f/build_files/dx/00-dx.sh) |
| Dev distroboxes (`gtk-dev`, `rust-dev`, `flutter-dev`, `ubuntu-pkg`, `debian-pkg`) and `ujust` recipes | [install-dev-boxes.sh](/build_files/scripts/install-dev-boxes.sh), [dev.ini](/build_files/distrobox/dev.ini), [60-custom.just](/build_files/just/60-custom.just) | _N/A_ |
| Optipng, flatpak-builder, Yakuake | [install-utilities.sh](/build_files/scripts/install-utilities.sh) | _N/A_ |
| Signature verification policy for this image | [configure-signing.sh](/build_files/scripts/configure-signing.sh) | _N/A_ |
| Stale-image desktop warning | [install-image-age-check.sh](/build_files/scripts/install-image-age-check.sh) | _N/A_ |

### Optional (disabled in [build.sh](/build_files/build.sh))

| Package | File | Credits |
|---------|------|---------|
| 1Password Edge channel | [install-1password.sh](/build_files/scripts/install-1password.sh) `edge` | see above |
| Brave Browser (`brave-browser`) | [install-brave.sh](/build_files/scripts/install-brave.sh) | _N/A_ |
| Insync (`insync`) | [install-insync.sh](/build_files/scripts/install-insync.sh) | [ebits21/insync-distrobox](https://github.com/ebits21/insync-distrobox/blob/main/make-insync-container.sh) |
| Vivaldi Browser (`vivaldi-stable`) | [install-vivaldi.sh](/build_files/scripts/install-vivaldi.sh) | _N/A_ |

## Switch to This Image

From your bootc system, run the following command:
```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/bluesabre/bazzite-blue
```
This queues the image for the next reboot. `--enforce-container-sigpolicy` makes bootc refuse images that aren't signed with this repo's [cosign key](./cosign.pub).

If you're switching from stock Bazzite, your current system doesn't yet know this image's signing key, so the first switch may need to drop `--enforce-container-sigpolicy`. After you reboot into this image, the policy is installed and later updates are verified.

## Usage Notes

### Stale-image warning

A per-user timer (`bazzite-blue-image-age.timer`) checks the booted image's build date once a day. If the image is more than 3 days old, which usually means the daily build is failing, it shows a desktop notification. To check by hand:

```bash
systemctl --user start bazzite-blue-image-age.service
journalctl --user -u bazzite-blue-image-age.service -n 5
```

When a scheduled build on `main` fails, CI also opens a GitHub issue labelled `build-failure`. The next successful build closes it.

## Making Changes

All changes go through pull requests:

1. **Iterate locally**: `just build` builds the image with podman, and `just lint` runs ShellCheck (in a container if it isn't installed).
2. **Open a PR** from a branch in this repository. CI builds the image and publishes it as `ghcr.io/bluesabre/bazzite-blue:pr-<N>`, signed and separate from `latest`.
3. **Optionally boot it** to test on real hardware:
   ```bash
   sudo bootc switch --enforce-container-sigpolicy ghcr.io/bluesabre/bazzite-blue:pr-<N>
   # reboot, test, then go back:
   sudo bootc switch --enforce-container-sigpolicy ghcr.io/bluesabre/bazzite-blue:latest
   ```
4. **Merge** once the "Build and push image" and "Lint" checks are green. Closing the PR deletes its `pr-<N>` image.

PRs from forks and from Dependabot are built but not published.

### Recommended repository setting

Under **Settings → Rules → Rulesets**, add a ruleset for `main` that requires a pull request and the status checks **Build and push image** and **Lint scripts and Justfile**. Add yourself to the bypass list for emergencies.

# Repository Contents

| Path | Purpose |
|------|---------|
| [Containerfile](./Containerfile) | Entry point: base image, runs `build.sh`, then `bootc container lint` |
| [build_files/build.sh](./build_files/build.sh) | Calls each installer in `build_files/scripts/` |
| [.github/workflows/build.yml](./.github/workflows/build.yml) | Daily/push/PR build, rechunk, push to GHCR, cosign signing, failure issues |
| [.github/workflows/lint.yml](./.github/workflows/lint.yml) | ShellCheck and Justfile syntax |
| [.github/workflows/cleanup-pr.yml](./.github/workflows/cleanup-pr.yml) | Deletes `pr-<N>` images when a PR closes |
| [.github/workflows/build-disk.yml](./.github/workflows/build-disk.yml) | Builds qcow2/ISO disk images with bootc-image-builder |
| [Justfile](./Justfile) | Local build, rechunk, VM, and lint recipes (`just --list`) |

For details on disk images, ArtifactHub, and the Justfile recipes, see the upstream [ublue-os/image-template README](https://github.com/ublue-os/image-template#readme).

### Incus

Incus is installed and socket-activated. Run the one-time setup as your user, then reboot. Logging out of Plasma often keeps the session running, so the new group won't apply. To use Incus right away in one terminal, run `newgrp incus-admin`.

```bash
ujust setup-incus
```

This adds you to `incus-admin`, gives root subordinate ID ranges, runs `incus admin init --minimal` and trusts `incusbr0` in firewalld. It refuses to run if Bazzite's rootful `incus` distrobox exists, because both would use `/var/lib/incus`.

### Development boxes

Toolchains live in distroboxes rather than the image. Create one or all of them:

```bash
ujust setup-dev-box gtk-dev      # Fedora: GTK 3/4, libadwaita, Vala, Meson, PyGObject, Blueprint
ujust setup-dev-box rust-dev     # Fedora: rustup (toolchain in ~/.cargo), GTK libs for gtk-rs
ujust setup-dev-box flutter-dev  # Ubuntu: Flutter Linux desktop (SDK in ~/.local/share/flutter)
ujust setup-dev-box ubuntu-pkg   # Ubuntu 26.10: pbuilder-dist, ubuntu-dev-tools, lintian, debuild
ujust setup-dev-box debian-pkg   # Debian unstable: the same tools, for current Debian requirements
ujust setup-dev-box              # all five
```

`ubuntu-pkg` and `debian-pkg` are set up so `pbuilder-dist` works in a rootless box. Each has its own PID namespace, and its `/etc/pbuilderrc` skips `/sys` and bind-mounts real `/dev/null`, `/dev/zero` and friends into the chroot. Source repositories (`deb-src`) are enabled, so `apt-get source` and `sudo apt-get build-dep` work. Typical use:

```bash
distrobox enter ubuntu-pkg
pbuilder-dist stonking create        # or resolute, sid, trixie, ... (either box can target either distro)
pbuilder-dist stonking build foo_1.0-1.dsc
```

Chroot tarballs in `~/pbuilder` belong to the box's root, which maps to a subordinate UID on the host, so delete them from inside the box with `sudo`. Build results are owned by you. `ubuntu-pkg` is pinned to `ubuntu:26.10`, so bump the tag in `dev.ini` when a newer release ships. `debian-pkg` tracks `debian:unstable` and picks up the latest image whenever it's recreated.

The definitions are in `/usr/share/bazzite-blue/distrobox/dev.ini`. To rebuild a box from scratch, run `distrobox assemble create --replace --file /usr/share/bazzite-blue/distrobox/dev.ini --name <box>`. To use VS Code with a box, use the Dev Containers extension's **Attach to Running Container** (with `dev.containers.dockerPath` set to `podman`).
