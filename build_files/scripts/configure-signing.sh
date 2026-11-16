#!/usr/bin/env bash

# Teach podman/bootc to verify this image's cosign signatures, so that
# `bootc switch --enforce-container-sigpolicy` and future updates reject
# unsigned or tampered images.

set ${SET_X:+-x} -eou pipefail

IMAGE_REF="ghcr.io/bluesabre/bazzite-blue"
KEY_PATH="/etc/pki/containers/bazzite-blue.pub"
POLICY="/etc/containers/policy.json"

echo "Configuring signature verification for ${IMAGE_REF}"

install -Dm644 /ctx/cosign.pub "$KEY_PATH"

mkdir -p /etc/containers/registries.d
cat >/etc/containers/registries.d/bazzite-blue.yaml <<EOF
docker:
  ${IMAGE_REF}:
    use-sigstore-attachments: true
EOF

tmp_policy="$(mktemp)"
jq --arg ref "$IMAGE_REF" --arg key "$KEY_PATH" \
    '.transports.docker[$ref] = [{
        "type": "sigstoreSigned",
        "keyPath": $key,
        "signedIdentity": {"type": "matchRepository"}
    }]' "$POLICY" >"$tmp_policy"
install -m644 "$tmp_policy" "$POLICY"
rm -f "$tmp_policy"
