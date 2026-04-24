_: {
  flake.modules.homeManager."programs/filebot" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    home.packages = with pkgs; [filebot];
    # sops.secrets."filebot-license" = {
    #   path = "${config.xdg.dataHome}/filebot/data/.license";
    # };
  };
}
