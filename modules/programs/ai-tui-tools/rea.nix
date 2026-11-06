{config, ...}: {
  # NixOS side: usbmon for USB packet capture + wireshark (dumpcap wrapper is
  # restricted to the `wireshark` group), and the rea CLI (uses pkgs.local,
  # proven at the nixos level).
  flake.modules.nixos."programs/rea" = {
    pkgs,
    lib,
    ...
  }: {
    imports = config.flake.lib.resolve ["programs/python"];
    boot.kernelModules = ["usbmon"];
    programs.wireshark.enable = true;
    users.users.${config.flake.meta.user.username}.extraGroups = [
      "wireshark" # setcap'd dumpcap wrapper → usbmon packet capture
    ];
    # usbmon char nodes come up as root:root 0600 (devtmpfs default). The
    # wrapper's cap set (net_raw, net_admin) does not include dac_override,
    # so without this rule open(2) on /dev/usbmon<N> fails with EACCES even
    # for wireshark-group members.
    services.udev.extraRules = ''
      SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0660"
    '';
    environment.systemPackages = [pkgs.local.rea];
  };

  # Home-manager side: interactive/static RE toolchain.
  flake.modules.homeManager."programs/rea" = {pkgs, ...}: {
    home.packages = with pkgs; [
      ghidra # REA drives this for native decompilation
      usbutils
    ];

    # Python packages ride on the shared user python from programs/python
    # (a separate python3.withPackages env would collide with it in
    # home-manager-path). Requires "programs/python" to be imported too.
    programs.python.extraPackages = with pkgs.python3Packages; [
      frida-python # dynamic instrumentation: hook libevdi/libusb in DisplayLinkManager
      pyserial
      construct
      kaitaistruct
    ];
  };
}
