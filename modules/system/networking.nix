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

  # Preservation companion for "system" (NetworkManager is enabled above).
  # `config.flake.lib.resolve` imports it (together with the base preservation
  # module) automatically because of the "preservation/" prefix. Upstream
  # ignores `preserveAt` until `preservation.enable` is true.
  flake.modules.nixos."preservation/system" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # Saved connections and NetworkManager's keyfile state.
      "/etc/NetworkManager/system-connections"
      "/var/lib/NetworkManager"

      # sops-nix age identity (declared in the "system" module itself). Nothing
      # else survives without it: every secret fails to decrypt at activation.
      # Seed before first boot with: age-keygen -pq -o /persistent/var/lib/sops-nix/key.txt
      "/var/lib/sops-nix"
    ];
  };
}
