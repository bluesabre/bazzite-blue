# vim: set ft=make :
# Bazzite Blue recipes, imported by /usr/share/ublue-os/justfile

# Set up native Incus for the current user (group, idmaps, init, firewall)
[group("bazzite-blue")]
setup-incus:
    #!/usr/bin/bash
    set -euo pipefail
    if [[ $(id -u) -eq 0 ]]; then
      echo "Please run this as your user, not root."
      exit 1
    fi

    # Bazzite's rootful incus distrobox would fight over /var/lib/incus and incusbr0.
    if sudo podman container exists incus 2>/dev/null; then
      echo "Bazzite's rootful 'incus' distrobox exists. Remove it first:"
      echo "  distrobox rm --root incus"
      exit 1
    fi

    # bootc keeps a locally edited /etc/group, so the incus-admin group from
    # the image may be missing. Let sysusers create it, then fall back to /usr/lib/group.
    if ! getent group incus-admin >/dev/null; then
      sudo systemd-sysusers
    fi
    if ! grep -q '^incus-admin:' /etc/group && grep -q '^incus-admin:' /usr/lib/group 2>/dev/null; then
      grep '^incus-admin:' /usr/lib/group | sudo tee -a /etc/group >/dev/null
    fi
    if ! getent group incus-admin | cut -d: -f4 | tr ',' '\n' | grep -qx "$USER"; then
      echo "Adding $USER to incus-admin"
      sudo usermod -aG incus-admin "$USER"
    fi

    # Root needs subordinate id ranges for unprivileged containers.
    idmap_changed=false
    for f in /etc/subuid /etc/subgid; do
      if ! grep -q '^root:' "$f"; then
        echo "root:1000000:1000000000" | sudo tee -a "$f" >/dev/null
        idmap_changed=true
      fi
    done
    if $idmap_changed && systemctl is-active -q incus.service; then
      sudo systemctl restart incus.service
    fi

    # Initialize with defaults (dir storage pool, incusbr0 bridge) if needed.
    if [[ -z "$(sudo incus storage list -f csv)" ]]; then
      echo "Initializing Incus with defaults"
      sudo incus admin init --minimal
    fi

    # Let instances on incusbr0 reach DHCP/DNS through firewalld.
    if systemctl is-active -q firewalld; then
      if ! sudo firewall-cmd -q --permanent --zone=trusted --query-interface=incusbr0; then
        sudo firewall-cmd -q --permanent --zone=trusted --add-interface=incusbr0
        sudo firewall-cmd -q --reload
      fi
    fi

    # Logging out of Plasma often keeps the user session alive, so the new group
    # only shows up reliably after a reboot.
    if ! id -nG | tr ' ' '\n' | grep -qx incus-admin; then
      echo "Incus is ready. Reboot to use incus without sudo in every session."
      echo "To use it right away in this terminal, run: newgrp incus-admin"
    else
      echo "Incus is ready."
    fi

# Create Bazzite Blue dev distroboxes: gtk-dev, rust-dev, flutter-dev, or all
[group("bazzite-blue")]
setup-dev-box BOX="all":
    #!/usr/bin/bash
    set -euo pipefail
    ini=/usr/share/bazzite-blue/distrobox/dev.ini
    case "{{ BOX }}" in
      all) boxes=(gtk-dev rust-dev flutter-dev) ;;
      gtk-dev|rust-dev|flutter-dev) boxes=("{{ BOX }}") ;;
      *)
        echo "Usage: ujust setup-dev-box [gtk-dev|rust-dev|flutter-dev|all]"
        exit 1
        ;;
    esac

    for box in "${boxes[@]}"; do
      echo "==> $box"
      distrobox assemble create --file "$ini" --name "$box"
      case "$box" in
        rust-dev)
          distrobox enter rust-dev -- bash -c '
            set -e
            if [ ! -x "$HOME/.cargo/bin/cargo" ]; then
              rustup-init -y --no-modify-path
            fi
            "$HOME/.cargo/bin/cargo" --version
          '
          echo "Add to ~/.bashrc to put cargo on PATH inside rust-dev:"
          echo '  if [ "${CONTAINER_ID:-}" = rust-dev ]; then . "$HOME/.cargo/env"; fi'
          ;;
        flutter-dev)
          distrobox enter flutter-dev -- bash -c '
            set -e
            sdk="$HOME/.local/share/flutter"
            if [ ! -d "$sdk" ]; then
              git clone -b stable https://github.com/flutter/flutter.git "$sdk"
            fi
            "$sdk/bin/flutter" config --enable-linux-desktop
            "$sdk/bin/flutter" doctor
          '
          echo "Add to ~/.bashrc to put flutter on PATH inside flutter-dev:"
          echo '  if [ "${CONTAINER_ID:-}" = flutter-dev ]; then export PATH="$HOME/.local/share/flutter/bin:$PATH"; fi'
          ;;
      esac
    done

    echo "Enter a box with: distrobox enter <name>"
