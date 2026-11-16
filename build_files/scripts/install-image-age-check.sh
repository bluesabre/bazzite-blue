#!/usr/bin/env bash

# Install a per-user timer that warns on the desktop when the booted image
# is getting old. This catches every reason updates silently stop arriving:
# failing scheduled builds, failed pushes, expired secrets, a stuck updater.

set ${SET_X:+-x} -eou pipefail

echo "Installing image age check"

mkdir -p /usr/libexec/bazzite-blue
cat >/usr/libexec/bazzite-blue/image-age-check <<'EOF'
#!/usr/bin/env bash
# Warn when the booted bazzite-blue image is older than MAX_AGE_DAYS.
set -euo pipefail

MAX_AGE_DAYS="${BAZZITE_BLUE_MAX_IMAGE_AGE_DAYS:-3}"

# rpm-ostree works unprivileged (bootc status needs root). For container
# deployments, .timestamp is the image's build time in epoch seconds.
built="$(rpm-ostree status --json 2>/dev/null |
    jq -r '.deployments[] | select(.booted) | .timestamp // empty')" || true
if [[ -z "$built" ]]; then
    echo "Could not determine booted image timestamp; skipping." >&2
    exit 0
fi

now="$(date +%s)"
age_days=$(((now - built) / 86400))

echo "Booted image built $(date -d "@${built}") (${age_days} day(s) ago, limit ${MAX_AGE_DAYS})."

if ((age_days >= MAX_AGE_DAYS)); then
    notify-send --app-name="Bazzite Blue" --urgency=critical --icon=dialog-warning \
        "Bazzite Blue image is ${age_days} days old" \
        "Daily image builds may be failing. Check GitHub Actions for bluesabre/bazzite-blue, then run 'ujust update'."
fi
EOF
chmod 755 /usr/libexec/bazzite-blue/image-age-check

cat >/usr/lib/systemd/user/bazzite-blue-image-age.service <<'EOF'
[Unit]
Description=Warn when the booted Bazzite Blue image is stale
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=/usr/libexec/bazzite-blue/image-age-check
EOF

cat >/usr/lib/systemd/user/bazzite-blue-image-age.timer <<'EOF'
[Unit]
Description=Daily check that the booted Bazzite Blue image is recent

[Timer]
OnStartupSec=10min
OnUnitActiveSec=1d
Persistent=false

[Install]
WantedBy=timers.target
EOF

systemctl --global enable bazzite-blue-image-age.timer
