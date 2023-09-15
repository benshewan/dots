{ inputs, ... }:
{
  # Enables support for declarative flatpaks
  imports = [ inputs.flatpaks.homeManagerModules.default ];
  services.flatpak = {
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
    };

    packages = [
      "flathub:org.yuzu_emu.yuzu//stable"
    ];
  };
}
