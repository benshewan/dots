#!/usr/bin/env bash
# Build a host.
#
# Secrets are managed by sops-nix with per-host post-quantum age keys.
# If the host's key is missing, this script generates one (hybrid
# ML-KEM-768 + X25519), then installs it to /var/lib/sops-nix/key.txt.
# A freshly generated recipient must be added to .sops.yaml and the
# secrets re-wrapped with `sops updatekeys` before it can decrypt.
#
# Usage: ./bootstrap.sh <host> [switch|boot|test] (default: switch)

set -euo pipefail

HOST="${1:-}"
ACTION="${2:-switch}"

if [[ -z "$HOST" ]]; then
  echo "usage: $0 <host> [switch|boot|test]" >&2
  echo "hosts: navis, caelum" >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SOPS_YAML="${SCRIPT_DIR}/.sops.yaml"
KEY_DIR="${HOME}/.config/sops/age/hosts"
KEY_FILE="${KEY_DIR}/${HOST}.key"
INSTALLED_KEY="/var/lib/sops-nix/key.txt"

age_keygen() {
  if command -v age-keygen >/dev/null 2>&1; then
    age-keygen "$@"
  else
    nix shell nixpkgs#age -c age-keygen "$@"
  fi
}

if [[ ! -f "$KEY_FILE" ]]; then
  # A recipient for this host is already registered: a new key would produce a
  # different recipient and could not decrypt the existing secrets.
  if grep -q "&${HOST}\b" "$SOPS_YAML"; then
    echo "error: ${KEY_FILE} is missing, but '&${HOST}' is already a recipient in .sops.yaml." >&2
    echo "Generating a new key would not decrypt the existing secrets." >&2
    echo "Recover the key, or remove the old '&${HOST}' recipient and re-run to rotate." >&2
    exit 1
  fi

  echo "Generating a new post-quantum age key for '${HOST}'..."
  if [[ ! -d "$KEY_DIR" ]]; then
    mkdir -p "$KEY_DIR"
    chmod 700 "$KEY_DIR"
  fi
  age_keygen -pq -o "$KEY_FILE"
  chmod 600 "$KEY_FILE"
fi

RECIPIENT="$(age_keygen -y "$KEY_FILE")"

if ! grep -qF "$RECIPIENT" "$SOPS_YAML"; then
  echo "error: the recipient for '${HOST}' is not in .sops.yaml yet." >&2
  echo >&2
  echo "Add it under 'keys:' and to the relevant creation_rules:" >&2
  echo "  - &${HOST} ${RECIPIENT}" >&2
  echo >&2
  echo "Then re-wrap the secrets and re-run:" >&2
  echo "  nix shell nixpkgs#sops nixpkgs#age -c sops updatekeys secrets/common.yaml" >&2
  exit 1
fi

if [[ ! -f "$INSTALLED_KEY" ]]; then
  echo "Installing host key to ${INSTALLED_KEY}..."
  sudo install -Dm600 "$KEY_FILE" "$INSTALLED_KEY"
elif ! sudo cmp -s "$KEY_FILE" "$INSTALLED_KEY"; then
  echo "error: ${INSTALLED_KEY} exists and differs from ${KEY_FILE}." >&2
  echo "Refusing to overwrite it. Remove it first if you intend to rotate the host key." >&2
  exit 1
fi

exec sudo nixos-rebuild "$ACTION" --flake "${SCRIPT_DIR}#${HOST}"
