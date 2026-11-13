{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/orcaslicer" = {pkgs, ...}: {
    home.packages = with pkgs; [
      orca-slicer
    ];
  };

  # Preservation companion for "programs/orcaslicer" (auto-resolved by the
  # prefix). Audited live:
  # - .config/OrcaSlicer — the profile: user/ (user machine/process/filament
  #   presets), system/ (vendor profiles, OTA-updated), OrcaSlicer.conf,
  #   ota/ and the webview cache/ (Bambu-cloud login cookies).
  # - .local/share/orca-slicer — Chromium webview engine data including
  #   localstorage with the Bambu login session (losing it = re-login).
  # - .cache/orca-slicer — skip, plain cache.
  flake.modules.nixos."preservation/programs/orcaslicer" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".config/OrcaSlicer"
        ".local/share/orca-slicer"
      ];
    };
  };
}
