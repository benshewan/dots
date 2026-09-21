#!/usr/bin/env bash
# Build a host.
#
# Secrets are managed by sops-nix with per-host post-quantum age keys.
# The host's private key must exist at /var/lib/sops-nix/key.txt BEFORE
# activation, or sops cannot decrypt secrets. Provision it first:
#
#   sudo install -Dm600 ~/.config/sops/age/hosts/navis.key /var/lib/sops-nix/key.txt
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

if [[ ! -f /var/lib/sops-nix/key.txt ]]; then
  echo "error: /var/lib/sops-nix/key.txt is missing." >&2
  echo "Install the host's PQ age key first:" >&2
  echo "  sudo install -Dm600 ~/.config/sops/age/hosts/${HOST}.key /var/lib/sops-nix/key.txt" >&2
  exit 1
fi

exec sudo nixos-rebuild "$ACTION" --flake "${SCRIPT_DIR}#${HOST}"
