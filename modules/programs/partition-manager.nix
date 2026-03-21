{config, ...}: {
  flake.modules.nixos."programs/partition-manager" = {pkgs, ...}: {
    programs.partition-manager.enable = true;
    environment.systemPackages = with pkgs; [
      # Needed for partition manager exfat support
      exfatprogs
    ];
  };
}
