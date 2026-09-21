# dots

Ben's somewhat fancy Nix config

## Secrets

Secrets are managed by [sops-nix](https://github.com/Mic92/sops-nix) with
post-quantum age keys (hybrid X25519 + ML-KEM-768). Encrypted secrets live in
this repo under `secrets/`, so there is no separate private repo.

Recipient rules are in `.sops.yaml`:

- `secrets/common.yaml` — admin key + both hosts
- `secrets/hosts/<host>.yaml` — admin key + that host only

### Keys

Each host decrypts with its own PQ age identity at `/var/lib/sops-nix/key.txt`.
The admin key lives at `~/.config/sops/age/keys.txt` and is only needed to edit
secrets. It is never committed.

Generate them once (`age` from nixpkgs):

```bash
nix shell nixpkgs#age -c age-keygen -pq -o ~/.config/sops/age/keys.txt
nix shell nixpkgs#age -c age-keygen -pq -o ~/.config/sops/age/hosts/navis.key
nix shell nixpkgs#age -c age-keygen -pq -o ~/.config/sops/age/hosts/caelum.key
```

Add each public key (`age-keygen -y <file>`) as a recipient in `.sops.yaml`,
then run `sops updatekeys secrets/*.yaml`.

### Editing secrets

```bash
nix shell nixpkgs#sops nixpkgs#age -c sops secrets/common.yaml
```

### Bootstrapping a host

Install the host's private key before first activation, then build:

```bash
sudo install -Dm600 ~/.config/sops/age/hosts/navis.key /var/lib/sops-nix/key.txt
./bootstrap.sh navis
```

Replace `navis` with the target host (`caelum`, `navis`, ...). Optional second
arg: `switch` (default), `boot`, or `test`.
