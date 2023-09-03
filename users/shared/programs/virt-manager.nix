{ pkgs, ... }:
{

  home.packages = with pkgs; [
    virt-manager
  ];

  # Set default connection
  dconf.settings = {
  "org/virt-manager/virt-manager/connections" = {
    autoconnect = ["qemu:///system"];
    uris = ["qemu:///system"];
  };
};


}
