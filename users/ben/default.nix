{ inputs, username, flake-path, lib, ... }:
{
  # My main home config
  _module.args = { inherit inputs username; };
  imports = [
    ../shared
    ./programs
    ./themes
  ]
  # Not perfect as you need to have the desktop loaded before you can switch
  ++ lib.optional (builtins.getEnv "XDG_CURRENT_DESKTOP" == "Hyprland") ../shared/desktop-enviroments/hyprland
  ++ lib.optional (builtins.getEnv "XDG_CURRENT_DESKTOP" == "KDE") ../shared/desktop-enviroments/kde.nix
  ++ lib.optional (builtins.getEnv "XDG_CURRENT_DESKTOP" == "GNOME") ../shared/desktop-enviroments/gnome.nix;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  #  nixpkgs.config.allowUnfree = true; # This is borked for some reason
  nixpkgs.config.allowUnfreePredicate = _: true; # Workaround for the above borked option

  #  home.shellAliases = { };
  home.shellAliases = {
    home-switch = "home-manager switch --flake ${flake-path}#ben";
    sudo = "sudo -E";
    sudopath = "sudo env PATH=$PATH";
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";
}
