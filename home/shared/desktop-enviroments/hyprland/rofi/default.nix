{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    location = "center";
    terminal = lib.getExe pkgs.kitty;

    plugins = with pkgs; [
      rofi-calc
      rofi-bluetooth
      rofi-power-menu
    ];

    theme = let
      # Use `mkLiteral` for string-like values that should show without
      # quotes, e.g.:
      # {
      #   foo = "abc"; => foo: "abc";
      #   bar = mkLiteral "abc"; => bar: abc;
      # };
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        background = mkLiteral "#1E1D2FFF";
        background-alt = mkLiteral "#282839FF";
        foreground = mkLiteral "#D9E0EEFF";
        selected = mkLiteral "#7AA2F7FF";
        active = mkLiteral "#ABE9B3FF";
        urgent = mkLiteral "#F28FADFF";
      };
    };
  };
}
