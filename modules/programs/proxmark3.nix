{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/proxmark3" = {pkgs, ...}: {
    home.packages = with pkgs; [
      # stable branch for the Iceman client build; withGeneric builds the
      # client without requiring the device firmware version to match.
      (pkgs.stable.proxmark3.override {withGeneric = true;})
    ];
  };

  # Preservation companion for "programs/proxmark3" (auto-resolved by the
  # prefix). Everything the Iceman client keeps lives in one dir (0700):
  # command history (readline history.txt), preferences.json (saved on
  # quit), and per-session logs under logs/. Card dumps are saved to the
  # cwd, not here.
  flake.modules.nixos."preservation/programs/proxmark3" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        {directory = ".proxmark3"; mode = "0700";}
      ];
    };
  };
}
