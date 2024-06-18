{pkgs, ...}: {
  # Installed fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono" "RobotoMono"];})
    noto-fonts-cjk
    noto-fonts-emoji
  ];
}
