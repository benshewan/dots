{
  ...
}: {
  flake.modules.nixos.system = {config, ...}: {
    sops.secrets."github-netrc" = {
      owner = "root";
      group = "root";
      mode = "0400";
    };

    # Authenticate GitHub fetches made by the Nix daemon (flakes, tarballs)
    # to lift the 60 req/hr unauthenticated rate limit. The secret holds a
    # netrc file; nix.settings cannot interpolate a runtime secret's contents,
    # so we point the daemon at the decrypted file instead.
    nix.settings.netrc-file = config.sops.secrets."github-netrc".path;
  };
}
