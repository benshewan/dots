{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    # package = pkgs.thorium;
    commandLineArgs = ["--ozone-platform-hint=auto"];
  };
}
