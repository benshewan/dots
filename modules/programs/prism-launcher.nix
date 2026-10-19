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
      (prismlauncher.override {jdks = [openjdk8 zulu17 zulu21 zulu25];})
    ];
  };
}
