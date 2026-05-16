# dots

Ben's somewhat fancy Nix config

## Bootstrapping without secrets

For new machines without the private SSH key for the secrets repo.

```bash
./bootstrap.sh navis
```

Replace `navis` with target host (`caelum`, `navis`, ...). Optional second arg: `switch` (default), `boot`, or `test`.

The script passes `--override-input secrets path:./secrets-stub`. The stub lacks the yubikey sentinel file, so `flake.enableSecrets` auto-resolves to `false` — agenix modules drop out, user gets `initialPassword = "changeme"`. Change it after boot with `passwd`.

Once SSH access to the secrets repo works, rebuild normally:

```bash
sudo nixos-rebuild switch --flake .#navis
```

Secrets auto-detect and re-enable.
