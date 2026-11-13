{...} @ flake: let
  username = flake.config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/filebot" = {pkgs, ...}: {
    home.packages = with pkgs; [filebot];
  };
  flake.modules.nixos."programs/filebot" = {
    sops.secrets."filebot-license" = {
      owner = username;
      group = "users";
      path = "/home/${username}/.local/share/filebot/data/.license";
    };
    # sops-nix creates the secret's parent dirs as root (0755), which breaks
    # filebot (it mkdirs its cache under data/ as the user). Pre-create the
    # chain with the user's ownership; sops-install-secrets only fills in
    # missing dirs and leaves existing ones alone. Needed every boot since
    # the volatile root is wiped.
    #
    # Ordering trap: this host renders sops secrets during the INITRD
    # activation ("NixOS Activation", pre-switch_root), which is BEFORE the
    # stage-2 preservation mounts come up — the .license symlink it creates
    # at the volatile path is shadowed by the .local/share/filebot mount.
    # The L+ rule below re-creates the symlink INSIDE the mount in stage-2
    # tmpfiles (runs after the mount; also re-runs on every switch).
    systemd.tmpfiles.rules = [
      "d /home/${username}/.local/share/filebot 0755 ${username} users - -"
      "d /home/${username}/.local/share/filebot/data 0755 ${username} users - -"
      "L+ /home/${username}/.local/share/filebot/data/.license - - - - /run/secrets/filebot-license"
    ];
  };

  # Preservation companion for "programs/filebot" (auto-resolved by the
  # prefix). data/ holds prefs.properties (its own preferences store) plus
  # the .license symlink — which is (re)created inside the mount by a
  # tmpfiles L+ rule (see above: sops renders in the initrd, before these
  # mounts exist). Cache/logs ride along inside data/.
  flake.modules.nixos."preservation/programs/filebot" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".local/share/filebot"
      ];
    };
  };
}
