{
  inputs,
  outputs,
  config,
  ...
}: {
  # Enables support for declarative flatpaks
  imports = [inputs.nix-flatpak.homeManagerModules.nix-flatpak];
  services.flatpak = {
    enable = true;
    uninstallUnmanaged = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "flathub-beta";
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
    ];

    update = {
      onActivation = false; # Update when config is switched
      auto = {
        # update based on time
        enable = true;
        onCalendar = "weekly";
      };
    };
    overrides = {
      global = {
        # Force Wayland by default
        # Context.sockets = ["wayland" "!x11" "!fallback-x11"];

        Environment = {
          # Fix un-themed cursor in some Wayland apps
          XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

          # Force correct theme for some GTK apps
          # GTK_THEME = config.gtk.theme.name;
        };
        Context.filesystems = [
          # Needed to show cursor theme
          "/home/${outputs.username}/.icons/:ro"
          "/nix/store/:ro"
        ];
      };
      # "org.onlyoffice.desktopeditors".Context.sockets = ["x11"]; # No Wayland support
    };
  };
}
