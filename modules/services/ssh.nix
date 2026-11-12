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

  # Preservation companion for "services/ssh". `config.flake.lib.resolve`
  # imports it (together with the base preservation module) automatically
  # because of the "preservation/" prefix.
  #
  # The entries are declared unconditionally: the base module is always present
  # when this module is loaded, and upstream ignores `preservation.preserveAt`
  # until `preservation.enable` is true.
  flake.modules.nixos."preservation/services/ssh" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.files = [
      # Host keys: keep them stable across reboots and reinstalls. Symlinks
      # are fine here because sshd starts long after preservation has run.
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
