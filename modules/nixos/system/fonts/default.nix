{pkgs, ...}: {
  # Installed fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono" "RobotoMono"];})
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];
}
