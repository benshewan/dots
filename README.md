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

```bash
./bootstrap.sh navis
```

If `~/.config/sops/age/hosts/navis.key` does not exist, the script generates a
new PQ key with `age-keygen -pq`, installs it to `/var/lib/sops-nix/key.txt`,
and prints the recipient to add to `.sops.yaml`. Add it to the relevant
`creation_rules`, run `sops updatekeys secrets/common.yaml`, then re-run the
script. If the host is already registered in `.sops.yaml`, the script refuses to
generate a new key (it would not decrypt the existing secrets).

Replace `navis` with the target host (`caelum`, `navis`, ...). Optional second
arg: `switch` (default), `boot`, or `test`.
