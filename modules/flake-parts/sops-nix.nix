{inputs, ...}: {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.system = {pkgs, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];

    environment.systemPackages = [
      pkgs.sops
      pkgs.age
      # sops dispatches plugin identities through `age-plugin-<name>` on PATH.
      # The hardware-backed admin key (see .sops.yaml, admin_fido2) is a
      # fido2-hmac identity: decryption needs this binary + the YubiKey.
      # Host keys stay plain software identities, so sops-install-secrets
      # never needs the token.
      pkgs.age-plugin-fido2-hmac
    ];

    # Let the active seat's user open FIDO2 tokens over hidraw (the plugin
    # talks CTAP directly, no pcscd). Keyed on systemd's fido_id marker so it
    # covers any token, not just Yubico. SSH sessions get no seat: run sops
    # with sudo there, or edit secrets at the machine.
    services.udev.extraRules = ''
      SUBSYSTEM=="hidraw", ENV{ID_FIDO_TOKEN}=="1", TAG+="uaccess"
    '';

    sops = {
      # Per-host post-quantum age identity, provisioned out-of-band.
      # Generate/install with: age-keygen -pq -o /var/lib/sops-nix/key.txt
      age.keyFile = "/var/lib/sops-nix/key.txt";

      # All shared secrets live in one encrypted file in this repo.
      defaultSopsFile = ../../secrets/common.yaml;
      validateSopsFiles = true;
    };
  };

  # Preservation companion for "system" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/system" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # sops-nix age identity, mounted in the initrd for activation-time decryption.
      {
        directory = "/var/lib/sops-nix";
        inInitrd = true;
      }
    ];
  };
}
