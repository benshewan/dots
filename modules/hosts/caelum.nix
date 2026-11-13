{
  inputs,
  config,
  ...
}: let
  hostMeta = {
    name = "caelum";
    dnsServers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
  inherit (config) flake;
in {
  # caelum: QEMU/KVM guest on navis (libvirt domain "nixos-25.11")
  # Role: rehearsal host for the laptop config — LUKS + Secure Boot +
  # measured boot, erase-your-darlings btrfs root.

  flake = {
    # Host metadata
    meta.hosts = [hostMeta];

    modules.nixos."hosts/${hostMeta.name}" = {
      config,
      lib,
      pkgs,
      ...
    }: {
      # Rescue access from navis: works even if sops decryption fails (no
      # password hash set), since authorized keys are plain NixOS config.
      users.users.${flake.meta.user.username}.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMm0WtaU9Sb6g9UC+HFL6h4L+rOsHUMN/iWOU3qRGgaI benbshewan@gmail.com"];

      # Root rescue access, same key. Key-only: prohibit-password still forbids
      # password root login, and root has no declarative password at all.
      users.users.root.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMm0WtaU9Sb6g9UC+HFL6h4L+rOsHUMN/iWOU3qRGgaI benbshewan@gmail.com"];
      services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";

      # The q35 chipset emulates an iTCO watchdog which libvirt attaches
      # implicitly (invisible in the VM XML), and QEMU >= 8.0 makes its expiry
      # reset the guest. The guest kernel's iTCO_wdt driver arms that timer
      # with a 30s heartbeat — which expires during the poweroff + hibernation
      # restore window (restores take minutes) and hard-resets the VM with no
      # panic or journal trace. This is the documented KVM-guest failure mode
      # (LKML June 2026, Red Hat bugzilla #2137346); blacklist both modules.
      # (Stage-2 blacklist is sufficient: the iTCO platform device only exists
      # once lpc_ich loads, which happens after the initrd.)
      boot.blacklistedKernelModules = ["iTCO_wdt" "iTCO_vendor_support"];

      imports = flake.lib.resolve [
        # Desktop preset (users, security, development, shell, system, desktop environment)
        "presets/desktop"
        "presets/mangowm"
        "theme/gruvbox-dark"

        # Storage: encrypted btrfs layout + preservation state management
        "preservation"
        "system/preservation-home"
        "disk-layouts/luks-btrfs"

        # Secure Boot: lanzaboote with automatic key generation + enrollment
        "system/secure-boot"

        # display-managers/sddm comes from presets/mangowm; auto-login
        # replaces it with greetd's initial_session (testing VM: boot
        # straight into the session, no login prompt).
        "display-managers/auto-login"

        # Software
        "programs/adb"
        "programs/yazi"
        # "programs/dolphin"
        # "programs/npm"
        # "programs/python"
        # "services/kdeconnect"
        # "programs/obs"
        "programs/maki"
        # "programs/thunderbird"

        # State-audit batches rotate one set at a time through caelum.
        # Unloaded so far (companions stay in their module files): dolphin,
        # npm, python, kdeconnect, obs, thunderbird, steam, spotify,
        # obsidian, bottles, vscode, prism-launcher, partition-manager,
        # mongodb-compass, audio-relay, solaar, sunshine, chromium.
        # State-audit batches rotate one set at a time through caelum.
        # Unloaded so far (companions stay in their module files): dolphin,
        # npm, python, kdeconnect, obs, thunderbird, steam, spotify,
        # obsidian, bottles, vscode, prism-launcher, partition-manager,
        # mongodb-compass, audio-relay, solaar, sunshine, chromium,
        # webstorm, filebot, lan-mouse, helix, vivaldi, helium,
        # libreoffice, moonlight.
        "programs/proxmark3"
        "programs/distrobox"
        "programs/parsec"
        "programs/github-cli"
        "programs/orcaslicer"

        # hardware configuration
        ../../machines/caelum/hardware-configuration.nix

        # LUKS post-install provisioning: measured-boot pcrlock keyslot,
        # optional FIDO2 token, sops recovery keyslot (Secure Boot itself is
        # in modules/system/secure-boot.nix)
        ../../machines/caelum/provisioning.nix
      ];

      # Machine-specific parameters for the shared layout
      # (modules/disk-layouts/luks-btrfs.nix). The VM disk is /dev/vda and has
      # 16G of RAM, which the hibernation swapfile has to cover.
      modules.diskLayouts.luksBtrfs = {
        device = "/dev/vda";
        swapSize = 16 * 1024;
      };

      # Erase-your-darlings: everything durable is bind-mounted from
      # /persistent (see modules/disk-layouts/luks-btrfs.nix). Companions for ssh,
      # NetworkManager/sops and bluetooth attach automatically. User state is
      # granular (system/preservation-home) instead of a wholesale /home mount.
      modules.preservation.enable = true;
      modules.preservation.home = true;

      # Testing VM: passwordless sudo for the user, so rebuilds and audits
      # driven over SSH can sudo without interaction. Host-scoped on purpose
      # (modules/users.nix is shared with navis, which keeps its prompt).
      security.sudo.extraRules = [
        {
          users = [flake.meta.user.username];
          commands = [
            {
              command = "ALL";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];

      environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = 1;
      services.qemuGuest.enable = true;

      # greetd auto-login: same session line the mango desktop entry runs
      # (Exec=mango, DesktopNames=mango;wlroots), with the EDID-refresh
      # patched build from the mangowm module.
      modules.displayManager.autoLogin = {
        enable = true;
        command = "env XDG_CURRENT_DESKTOP=mango:wlroots ${lib.getExe pkgs.mango-edid-refresh}";
      };

      # /persistent/home/<user> is created by preservation itself (with the
      # user's homeMode), but the volatile /home/<user> is a real directory
      # on the wiped root: preservation only creates its children there, so
      # ownership has to be pinned explicitly.
      systemd.tmpfiles.rules = [
        "d /home/${flake.meta.user.username} 0700 ${flake.meta.user.username} users - -"
      ];

      # Home Manager configuration for user
      home-manager.users.${flake.meta.user.username} = {
        monitors = [
          {
            name = "name:Virtual-1";
            width = 3840;
            height = 2160;
            refreshRate = 60;
            scale = 2.0;
            primary = true;
          }
        ];
      };
    };

    networking.nameservers = hostMeta.dnsServers;

    # services.keylightd.enable = true;
  };
}
