{config, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user.name = config.night-sky.user.fullName;
      user.email = config.night-sky.user.email;

      pull.rebase = false;

      merge.tool = "vimdiff";
      merge.conflictstyle = "diff3";
      mergetool.prompt = false;
    };
  };
}
