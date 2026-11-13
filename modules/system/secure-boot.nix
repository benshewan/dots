{inputs, ...}: {
  # Lanzaboote: signs the NixOS kernel + initrd into a UKI and installs a
  # Secure Boot bootloader in place of systemd-boot.
  #
  # Nothing has to be run by hand: the key set is generated on the first boot
  # (autoGenerateKeys) and enrolled into the firmware by systemd-boot on the
  # next one (autoEnrollKeys).
  #   https://nix-community.github.io/lanzaboote/how-to-guides/automatically-generate-keys.html
  #   https://nix-community.github.io/lanzaboote/how-to-guides/automatically-enroll-keys.html
  # Neither can happen at install/switch time, only at boot, so:
  #   1. first boot: activation installs an UNSIGNED UKI (allowUnsigned
  #      defaults to autoGenerateKeys.enable), generate-sb-keys creates the key
  #      set in pkiBundle, prepare-sb-auto-enroll writes loader/keys/auto/*.auth
  #      to the ESP and (autoReboot) reboots immediately,
  #   2. the firmware enrolls those keys during that reboot,
  #   3. second boot onward: only our signed UKIs are accepted.
  # The reboot is unavoidable — firmware variables only take effect on the next
  # boot.
  #
  # Microsoft keys are enrolled as well (default): QEMU/virtio option ROMs are
  # MS-signed, and excluding them (allowBrickingMyMachine) would make the VM
  # unbootable. PK is replaced by our own key either way.
  #
  # The keys live in pkiBundle, which the caelum provisioning module keeps on
  # /persistent (erase-your-darlings would otherwise delete them every boot).
  flake-file.inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos."system/secure-boot" = {
    config,
    lib,
    ...
  }: {
    imports = [inputs.lanzaboote.nixosModules.lanzaboote];

    boot.lanzaboote = {
      enable = true;
      # sbctl's default location, on /persistent (see the companion below).
      pkiBundle = "/var/lib/sbctl";
      # Lanzaboote keeps every generation's kernel + initrd on the 1G ESP;
      # core.nix's systemd-boot limit of 25 would overflow it.
      #
      # 4 is also the hard ceiling for measured boot (systemd-pcrlock: PCR 4
      # variants = 2 loader variants x generations, max 8), and lanzaboote
      # asserts it. Hosts enabling boot.lanzaboote.measuredBoot — the
      # luks-btrfs layout does so automatically when lanzaboote is enabled,
      # see modules/disk-layouts/luks-btrfs.nix — rely on this staying <= 4.
      configurationLimit = 4;
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
        # Keep the firmware's pre-provisioned certificates in db/KEK. OEM
        # firmware (Framework, Dell, ...) needs its own trust anchors present
        # for firmware update capsules (fwupd) and some option ROMs; without
        # them those fail under Secure Boot.
        #
        # NOTE: this only affects the enrollment step (`sbctl enroll-keys
        # --firmware-builtin`), which runs once, from prepare-sb-auto-enroll
        # and only while /boot/loader/keys/auto/{PK,KEK,db}.auth do not exist.
        # On a system that is already enrolled it is inert until NVRAM is
        # reset / keys are re-enrolled.
        includeFirmwareBuiltinKeys = true;
      };
    };

    # core.nix enables systemd-boot for every host; lanzaboote replaces it.
    boot.loader.systemd-boot.enable = lib.mkForce false;
  };

  # Secure Boot key set and GUID, which must survive the root wipe to sign
  # future generations.
  flake.modules.nixos."preservation/system/secure-boot" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # sbctl key set (PK/KEK/db) and machine GUID.
      {directory = "/var/lib/sbctl";}
    ];
    # Parent directory, created before preservation's bind mount.
    systemd.tmpfiles.rules = ["d ${config.modules.preservation.persistentPath}/var/lib/sbctl 0700 root root - -"];
  };
}
