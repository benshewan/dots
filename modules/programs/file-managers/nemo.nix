{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside the NixOS
  # modules below, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/nemo" = {pkgs, ...}: {
    home.packages = with pkgs; [
      nemo
      # The fileroller extension shells out to the archiver, so file-roller
      # must be on PATH or the context menu silently does nothing.
      nemo-fileroller
      file-roller
    ];
  };

  # Mount backends: nemo has no KIO equivalent. Without gvfs it loses
  # trash:/ and network browsing, without udisks2 it cannot mount
  # removable media at all.
  flake.modules.nixos."programs/nemo" = {lib, ...}: {
    services.gvfs.enable = lib.mkDefault true;
    services.udisks2.enable = lib.mkDefault true;
  };

  # Preservation companion for "programs/nemo" (auto-resolved by the prefix).
  # Settings live in GSettings → ~/.config/dconf, preserved base-level by
  # system/preservation-home. Sidebar bookmarks are GTK-global
  # (~/.config/gtk-3.0/bookmarks) and belong to no single feature.
  flake.modules.nixos."preservation/programs/nemo" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username}.directories = [
      # User-created custom actions (.nemo_action) and scripts.
      ".local/share/nemo"
    ];
  };
}
