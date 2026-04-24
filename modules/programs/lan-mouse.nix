{inputs, ...}: {
  flake-file.inputs = {
    lan-mouse.url = "github:feschber/lan-mouse";
  };
  flake.modules.homeManager."programs/lan-mouse" = {
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.lan-mouse.homeManagerModules.default];
    programs.lan-mouse = {
      enable = true;
      # systemd = false;
      # package = inputs.lan-mouse.packages.${pkgs.stdenv.hostPlatform.system}.default
      # Optional configuration in nix syntax, see config.toml for available options
      # settings = { };
    };
  };
  flake.modules.nixos."programs/lan-mouse" = {
    pkgs,
    lib,
    ...
  }: {
    nix.settings.substituters = [
      "https://lan-mouse.cachix.org/"
    ];
    nix.settings.trusted-public-keys = [
      "lan-mouse.cachix.org-1:KlE2AEZUgkzNKM7BIzMQo8w9yJYqUpor1CAUNRY6OyM="
    ];
  };
}
