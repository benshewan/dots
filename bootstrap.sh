#!/usr/bin/env bash
# Build a host without the secrets SSH key.
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

exec sudo nixos-rebuild "$ACTION" \
  --flake "${SCRIPT_DIR}#${HOST}" \
  --override-input secrets "path:${SCRIPT_DIR}/secrets-stub"
