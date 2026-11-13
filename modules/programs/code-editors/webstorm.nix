{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/webstorm" = {pkgs, ...}: {
    home.packages = with pkgs; [
      (jetbrains.webstorm.override {
        vmopts = ''
          -Xmx4G
          -Xms2G
          -Dawt.toolkit.name=WLToolkit
        '';
      })
    ];
    # home.file.".config/JetBrains/prettier".source = pkgs.prettier;
  };

  # Preservation companion for "programs/webstorm" (auto-resolved by the
  # prefix). JetBrains writes outside XDG too:
  # - WebstormProjects (home root) — default projects dir.
  # - .local/share/JetBrains holds Daemon pid/socket (runtime, rides along)
  #   and the per-IDE user-plugin dir, which only appears after the first
  #   plugin install — whole dir so that isn't lost.
  # - Its java.util.prefs (usage stats opt-ins) live in ~/.java/.userPrefs/
  #   jetbrains — preserved with the granular home essentials.
  # - The jetbrains:// scheme registration (mimeapps.list via xdg-mime,
  #   sed -i) and the runtime-generated ~/.local/share/applications/
  #   jetbrainsd.desktop cannot be file-mounted; the IDE re-registers them
  #   on each launch, so both stay volatile.
  flake.modules.nixos."preservation/programs/webstorm" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".config/JetBrains"
        ".local/share/JetBrains"
        "WebstormProjects"
      ];
    };
  };
}
