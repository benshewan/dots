{
  inputs,
  outputs,
  config,
  ...
}: {
  # Enables support for declarative flatpaks
  imports = [inputs.flatpaks.homeManagerModules.default];
  services.flatpak = {
    enableModule = true;
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
    };
    overrides = {
      global = {
        filesystems = [
          # Needed to show cursor theme
          "/home/${outputs.username}/.icons/:ro"
          "/nix/store/:ro"
        ];
        # environment = {
        # GTK_THEME = config.gtk.theme.name;
        # };
      };
    };
  };
}
