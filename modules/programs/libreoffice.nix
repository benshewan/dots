{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/libreoffice" = {pkgs, ...}: {
    programs.libreoffice.enable = true;
  };

  # Preservation companion for "programs/libreoffice" (auto-resolved by the
  # prefix). Whole profile dir: registrymodifications.xcu (the settings
  # store — LibreOffice rewrites it wholesale, so a file mount would be
  # fragile), plus autotext, basic macros, autocorrect, user extensions and
  # template/gallery customizations.
  flake.modules.nixos."preservation/programs/libreoffice" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".config/libreoffice"
      ];
    };
  };
}
