{ pkgs, flake_path, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./nvidia.nix
      ../shared
    ];

  # System
  networking.hostName = "sirius";

  # Gaming
  programs.steam.enable = true;
  environment = {
    systemPackages = with pkgs; [
      mangohud
    ];
  };

  #Programs
  programs.fish.shellAbbrs = {
    nix-switch = "sudo nixos-rebuild switch --flake ${flake_path}#sirius";
  };
}
