{config, ...}: {
  programs.git = {
    enable = true;
    userName = config.night-sky.user.fullName;
    userEmail = config.night-sky.user.email;
    extraConfig = {
      pull.rebase = false;

      merge.tool = "vimdiff";
      merge.conflictstyle = "diff3";
      mergetool.prompt = false;
    };
  };
}
