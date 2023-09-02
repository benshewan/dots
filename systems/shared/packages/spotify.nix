{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nur.repos.nltch.spotify-adblock
    # spotify
    spicetify-cli
  ];
}
