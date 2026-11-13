{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside the NixOS
  # module below, which shadows `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.nixos."system/preservation-home" = {
    config,
    lib,
    ...
  }: {
    options.modules.preservation.home = lib.mkEnableOption ''
      granular user-state persistence. Registers per-user state with
      preservation instead of bind-mounting whole home directories. Requires
      modules.preservation.enable.
    '';

    config = lib.mkIf (config.modules.preservation.enable && config.modules.preservation.home) {
      preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
        # Only folders that belong to no single application live here. State
        # of a specific app is registered by that feature's own
        # `preservation/<feature>` companion instead (e.g.
        # `preservation/programs/maki` in
        # modules/programs/ai-tui-tools/maki/maki.nix), so it follows the
        # feature and is imported wherever the feature is.
        directories = [
          # XDG user dirs. No userDirs are declared, so apps create these on
          # demand; bind mounts make them survive the root rollback.
          "Documents"
          "Downloads"
          "Music"
          "Pictures"
          "Videos"

          # Identity and secrets, not owned by any module. (.ssh lives in
          # the ssh module's companion.)
          {directory = ".gnupg"; mode = "0700";}

          # Core tooling state: nix CLI profiles/history and Home Manager's
          # own state, both outside the declarative generations.
          ".local/state/nix"
          ".local/state/home-manager"

          # gnome-keyring's default collection (saved passwords of libsecret
          # clients).
          ".local/share/keyrings"

          # NSS Shared DB for client certificates. Shared by ALL
          # Chromium-based apps (Chromium itself and Electron) — opened via
          # the multi-process-safe sql: URI; default path since Chromium
          # M146, keeping legacy ~/.pki/nssdb if it exists. Firefox has its
          # own per-profile DB and never touches this.
          ".local/share/pki"

          # GSettings application database, shared by every desktop app
          # (loupe, foliate, nautilus, ...); belongs to no single feature.
          ".config/dconf"
        ];

        files = [
          # libpulse auth cookie (~/.config/pulse/cookie), shared by every
          # client of pipewire-pulse; belongs to no single feature. Written
          # once on first connection, so a file mount is safe.
          ".config/pulse/cookie"
        ];
      };
    };
  };
}
