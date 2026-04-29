_: {
  flake.modules.homeManager."programs/bottles" = {pkgs, ...}: {
    home.packages = [
      (pkgs.stable.bottles.override {
        removeWarningPopup = true;
      })
    ];
  };
}
