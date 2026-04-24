{config, ...}: {
  # NixOS
  flake.modules.nixos.system = {
    pkgs,
    lib,
    ...
  }: {
    networking.networkmanager.enable = true;
    networking.networkmanager.dns = "dnsmasq";
    users.users.${config.flake.meta.user.username}.extraGroups = ["networkmanager"];
  };
}
