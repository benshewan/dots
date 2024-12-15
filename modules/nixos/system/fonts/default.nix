{pkgs, ...}: {
  # Installed fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];
}
