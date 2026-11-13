{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/fish" = {
    pkgs,
    lib,
    ...
  }: {
    programs.fish = {
      enable = true;
      # Blank shell greeting
      shellInit = ''
        set fish_greeting
      '';
      interactiveShellInit = ''
        ${lib.getExe pkgs.nix-your-shell} fish | source
      '';
    };
  };

  # Preservation companion for "programs/fish" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/fish" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username}.directories = [
      # Shell history, generated functions, prompt state.
      ".local/share/fish"
    ];
  };
}
