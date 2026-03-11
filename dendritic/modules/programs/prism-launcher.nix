_: {
  flake.modules.homeManager."programs/prism-launcher" = {
    pkgs,
    lib,
    ...
  }: {
    programs.java = {
      enable = true;
      package = pkgs.jdk;
    };
    home.packages = with pkgs; [
      (prismlauncher.override {jdks = [jdk8 jdk17 jdk21 zulu25];})
    ];
  };
}
