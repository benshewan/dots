{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/chromium" = {
    pkgs,
    config,
    ...
  }: {
    programs.chromium = {
      enable = true;
      extensions = [
        {id = "ddkjiahejlhfcafbddmgiahcphecmpfh";} # uBlock Origin Lite
        {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
        {id = "gbmdgpbipfallnflgajpaliibnhdgobh";} # JSON Viewer
        {id = "lmhkpmbekcpmknklioeibfkpmmfibljd";} # Redux Dev Tools
        {id = "fmkadmapgofadopljbjfkapdkoienihi";} # React Dev Tools
      ];
    };
  };

  # Preservation companion for "programs/chromium" (auto-resolved by the
  # prefix). Whole profile dir, same rationale as .config/Code: Default/
  # (bookmarks, passwords, history), Local State and Local Storage are
  # LevelDB stores too fragile to split per entry. HM's generated
  # External Extensions/ symlinks ride along inside the mount.
  flake.modules.nixos."preservation/programs/chromium" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".config/chromium"
      ];
    };
  };
}
