{outputs, ...}: {
  imports = [
    ../../shared
    ./programs
    ./themes
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

  home.shellAliases = {
    sudo = "sudo -E";
    sudopath = "sudo env PATH=$PATH";
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${outputs.username}";
  home.homeDirectory = "/home/${outputs.username}";

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
