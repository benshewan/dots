_: {
  flake.modules.homeManager."programs/bottles" = {pkgs, ...}: {
    home.packages = [
      (pkgs.bottles.override {
        removeWarningPopup = true;
      })
    ];
  };
}
