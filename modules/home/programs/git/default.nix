{config, ...}: {
  programs.git = {
    enable = true;
    userName = config.night-sky.user.fullName;
    userEmail = config.night-sky.user.email;
    extraConfig = {
      pull.rebase = false;
    };
  };
}
