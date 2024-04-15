{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.night-sky; let
  cfg = config.night-sky.user;
  defaultIconFileName = "profile.jpg";
  defaultIcon = pkgs.stdenvNoCC.mkDerivation {
    name = "default-icon";
    src = ./. + "/${defaultIconFileName}";

    dontUnpack = true;

    installPhase = ''
      cp $src $out
    '';

    passthru = {fileName = defaultIconFileName;};
  };
  # propagatedIcon =
  #   pkgs.runCommandNoCC "propagated-icon"
  #   {passthru = {fileName = cfg.icon.fileName;};}
  #   ''
  #     local target="$out/share/plusultra-icons/user/${cfg.name}"
  #     mkdir -p "$target"
  #     cp ${cfg.icon} "$target/${cfg.icon.fileName}"
  #   '';
in {
  options.night-sky.user = with types; {
    name = mkOpt str "ben" "The name to use for the user account.";
    fullName = mkOpt str "Ben Shewan" "The full name of the user.";
    email = mkOpt str "benbshewan@gmail.com" "The email of the user.";
    initialPassword =
      mkOpt str "password"
      "The initial password to use when the user is first created.";
    icon =
      mkOpt (nullOr package) defaultIcon
      "The profile picture to use for the user.";
    prompt-init = mkBoolOpt true "Whether or not to show an initial message when opening a new shell.";
    extraGroups = mkOpt (listOf str) [] "Groups for the user to be assigned.";
    extraOptions =
      mkOpt attrs {}
      (mdDoc "Extra options passed to `users.users.<name>`.");
  };

  config = {
    users.groups = {
      "${config.night-sky.user.name}" = {};
    };
    users.users.${cfg.name} =
      {
        isNormalUser = true;
        description = cfg.fullName;

        inherit (cfg) name initialPassword;

        home = "/home/${cfg.name}";
        group = "users";

        shell = pkgs.fish;

        uid = 1000;
        extraGroups = ["wheel" "docker" "video" "libvirtd" "plugdev" "${config.night-sky.user.name}"] ++ cfg.extraGroups;
      }
      // cfg.extraOptions;
  };
}
