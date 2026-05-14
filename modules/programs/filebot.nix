{...} @ flake: {
  flake.modules.homeManager."programs/filebot" = {pkgs, ...}: {
    home.packages = with pkgs; [filebot];
  };
  flake.modules.nixos."programs/filebot" = {pkgs, ...}: {
    age.secrets."filebot-license" = {
      rekeyFile = ../../secrets/filebot.age;
      owner = flake.config.flake.meta.user.username;
      group = "users";
      path = "/home/${flake.config.flake.meta.user.username}/.local/share/filebot/data/.license";
    };
  };
}
