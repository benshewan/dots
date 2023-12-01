{
  pkgs,
  config,
  ...
}: let
  color = config.colorScheme.colors;
in {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock;
    settings = {
      screenshots = true;
      clock = true;
      indicator = true;

      # Colors
      # image = "${../../../../wallpapers/nix-black-4k.png}";
      # ring-color = color.base0D;
      # text-color = color.base05;
      # inside-color = color.base01;

      # ring-ver-color = color.base0E;
      # text-ver-color = color.base05;
      # inside-ver-color = color.base01;

      # ring-clear-color = color.base0A;
      # text-clear-color = color.base05;
      # inside-clear-color = color.base01;

      # ring-wrong-color = color.base06;
      # text-wrong-color = color.base05;
      # inside-wrong-color = color.base01;

      # ring-caps-lock-color = color.base06;
      # text-caps-lock-color = color.base05;
      # inside-caps-lock-color = color.base01;

      # key-hl-color = color.base0B;
      # caps-lock-key-hl-color = color.base0B;

      # bs-hl-color = color.base08;
      # caps-lock-bs-hl-color = color.base08;

      # Grace
      grace = 2;
      grace-no-mouse = true;

      # Effects
      fade-in = 0.2;
      effect-blur = "5x3";
      # effect-scale = 1;
    };
  };
}
