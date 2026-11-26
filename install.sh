#!/usr/bin/env bash
set -euo pipefail

# The host's own age identity, not an admin key. sops-nix expects it at
# /var/lib/sops-nix/key.txt; staging it under persistent/ puts it where the
# preservation bind mount will find it on the installed system.
host_key="$HOME/Documents/sops/age/hosts/navis.key"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Persistent copy: this is what the initrd preservation mount exposes as
# /var/lib/sops-nix after the first boot.
install -Dm600 "$host_key" "$tmp/persistent/var/lib/sops-nix/key.txt"
# Volatile copy for nixos-install's activation so setupSecretsForUsers succeeds
# during the install too. The erase-your-darlings rollback discards it.
install -Dm600 "$host_key" "$tmp/var/lib/sops-nix/key.txt"

SOPS_AGE_KEY_FILE="$host_key" nix shell nixpkgs#sops nixpkgs#age \
  -c sops -d --output-type json secrets/hosts/navis.yaml \
  | nix shell nixpkgs#jq -c jq -rj '.["luks-passphrase"]' > "$tmp/luks-passphrase"

# Never let disko format the disk with an empty/missing passphrase.
test -s "$tmp/luks-passphrase"

nix run nixpkgs#nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config machines/navis/hardware-configuration.nix \
  --extra-files "$tmp" \
  --disk-encryption-keys /tmp/luks-passphrase "$tmp/luks-passphrase" \
  --flake .#navis nixos@192.168.2.83
