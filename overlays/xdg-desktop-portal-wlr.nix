{lib, ...}: final: prev: {
  xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (old: {
    src = final.fetchFromGitHub {
      owner = "funk443";
      repo = "xdg-desktop-portal-wlr";
      rev = "74be7063347880f6bf98689e24dd9a6e98032405";
      sha256 = "125rsvls0gyc7a0lspvrqm54ckplfvd18q963yfmq47d6n3im6gr";
    };
  });
}
