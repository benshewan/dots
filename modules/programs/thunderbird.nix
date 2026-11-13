{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/thunderbird" = {pkgs, ...}: {
    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird.override {
        extraPolicies = {
          DontCheckDefaultBrowser = true;
        };
      };
      profiles = {
        default = {
          isDefault = true;
        };
      };
    };
  };

  # Preservation companion for "programs/thunderbird" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/thunderbird" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username}.directories = [
      # Profile data: accounts, mail, calendar and extension state.
      {directory = ".thunderbird"; mode = "0700";}
    ];
  };
}
