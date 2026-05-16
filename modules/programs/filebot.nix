{
  inputs,
  lib,
  ...
} @ flake: let
  enableSecrets = flake.config.flake.enableSecrets;
  username = flake.config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/filebot" = {pkgs, ...}: {
    home.packages = with pkgs; [filebot];
  };
  flake.modules.nixos."programs/filebot" = {lib, ...}:
    lib.optionalAttrs enableSecrets {
      age.secrets."filebot-license" = {
        rekeyFile = inputs.secrets + "/filebot.age";
        owner = username;
        group = "users";
        path = "/home/${username}/.local/share/filebot/data/.license";
      };
    };
}
