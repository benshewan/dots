{
  config,
  ...
}: let
  # programs/rea needs the user python env from programs/python, so import it
  # here rather than relying on the host to resolve it. The key matches what
  # flake.lib.resolveHm generates (see modules/flake-parts/lib.nix), so when a
  # host resolves both, the module system deduplicates them into one instance.
  importPython = {
    key = "dendritic-hm-programs/python";
    imports = [config.flake.modules.homeManager."programs/python"];
  };
in {
  # NixOS side: usbmon for USB packet capture + wireshark (with dumpcap group setup),
  # and the rea CLI (uses pkgs.local, proven at the nixos level).
  flake.modules.nixos."programs/rea" = {
    pkgs,
    lib,
    ...
  }: {
    boot.kernelModules = ["usbmon"];
    programs.wireshark.enable = true;
    environment.systemPackages = [pkgs.local.rea];
  };

  # Home-manager side: interactive/static RE toolchain.
  flake.modules.homeManager."programs/rea" = {
    pkgs,
    ...
  }: {
    imports = [importPython];

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
