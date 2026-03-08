_: {
  flake.modules.nixos.system = {pkgs, ...}: {
    # Some default global fonts
    fonts.enableDefaultPackages = true;
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.roboto-mono
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };
}
