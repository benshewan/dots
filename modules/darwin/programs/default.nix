{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
  ];

  homebrew = {
    enable = true;

    global.autoUpdate = false;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };
  };
}
