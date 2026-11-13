_: {
  flake.modules.nixos."services/ssh" = {pkgs, ...}: {
    programs.ssh.startAgent = true;
    services.openssh = {
      enable = true;
      settings = {
        # Forbid root login through SSH.
        PermitRootLogin = "no";
        # Use keys only. Remove if you want to SSH using password (not recommended)
        PasswordAuthentication = false;
      };
      # Make some host keys
      hostKeys = [
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };

  # Preservation companion for "services/ssh" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/services/ssh" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.files = [
      # SSH host keys, symlinked so they survive reboots and reinstalls.
      {
        file = "/etc/ssh/ssh_host_ed25519_key";
        how = "symlink";
        configureParent = true;
        mode = "0600";
      }
      {
        file = "/etc/ssh/ssh_host_ed25519_key.pub";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/etc/ssh/ssh_host_rsa_key";
        how = "symlink";
        configureParent = true;
        mode = "0600";
      }
      {
        file = "/etc/ssh/ssh_host_rsa_key.pub";
        how = "symlink";
        configureParent = true;
      }
    ];
  };
}
