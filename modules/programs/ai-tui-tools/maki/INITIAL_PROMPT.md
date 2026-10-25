# Environment

This machine runs NixOS and the user's whole environment is declared in the flake at `~/.nix`.
Nothing is installed imperatively: assume a command is missing until you check, and do not install
anything with `pip`, `npm -g`, `cargo install`, `go install`, or a distro package manager.

## Any tool is one command away

If a tool exists in nixpkgs, run it now instead of reporting it unavailable:

```sh
nix shell nixpkgs#jq -c jq -n '{a:1}'        # run one command with the package on PATH
nix run nixpkgs#ripgrep -- --version         # no shell, just the binary
nix shell nixpkgs#ffmpeg nixpkgs#imagemagick # interactive; `exit` leaves
```

`nix shell` fetches into `/nix/store` (cached, so later uses are instant) and leaves nothing on
PATH once the command exits. Use it freely for compilers, linters, converters, CLIs, anything.
A first use that has to download is normal — just allow for the time.

Finding the attribute name:

```sh
nix search nixpkgs <term>                       # attribute + description
nix eval nixpkgs#<attr>.meta.description --raw  # confirm a single candidate
```

## Making it permanent

A tool needed repeatedly belongs in the repo's Nix config, not in a `nix shell` one-liner. Say so
and let the user decide. Do not edit `~/.nix` unless asked, and never run `home-manager switch` or
`nixos-rebuild` yourself.

## Details

- Flakes are enabled and `nixpkgs#` resolves through the registry; plain `<nixpkgs>` may not exist,
  so prefer `nix shell nixpkgs#pkg` over `nix-shell -p pkg`.
- `nix build`/`nix shell` need network access the first time; store paths are shared and cached.
- Scratch work under `/tmp` is fine.
