{inputs, ...} @ flake: {
  flake-file.inputs = {
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    noctalia-greeter.inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.nixos."display-managers/noctalia-greeter" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (config.lib.stylix.colors) withHashtag;
    palette = {
      primary = withHashtag.base0D;
      on_primary = withHashtag.base07;
      secondary = withHashtag.base0C;
      on_secondary = withHashtag.base07;
      tertiary = withHashtag.base0E;
      on_tertiary = withHashtag.base07;
      error = withHashtag.base08;
      on_error = withHashtag.base07;
      surface = withHashtag.base00;
      on_surface = withHashtag.base05;
      surface_variant = withHashtag.base01;
      on_surface_variant = withHashtag.base04;
      outline = withHashtag.base03;
      shadow = withHashtag.base00;
      hover = withHashtag.base02;
      on_hover = withHashtag.base05;
    };
    wallpaperPath = toString config.stylix.image;
    appearanceManifest = builtins.toJSON {
      version = 1;
      theme_mode = "dark";
      inherit palette;
      wallpaper = {
        path = wallpaperPath;
        fill_mode = "crop";
      };
    };
    manifest = pkgs.writeText "noctalia-greeter-appearance.json" appearanceManifest;
    greeterUser = config.services.greetd.settings.default_session.user;
    greeterGroup = "greeter";
  in {
    imports = [inputs.noctalia-greeter.nixosModules.default];

    services.xserver.displayManager.lightdm.enable = lib.mkDefault false;

    programs.noctalia-greeter = {
      enable = true;
    };

    system.activationScripts.noctalia-greeter-appearance = ''
      install -Dm644 -o ${greeterUser} -g ${greeterGroup} ${manifest} /var/lib/noctalia-greeter/appearance.json
    '';
  };
}
