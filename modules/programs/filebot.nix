{
  ...
} @ flake: let
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
  };
}
