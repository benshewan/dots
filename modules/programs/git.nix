{config, ...}: {
  flake.modules.homeManager."programs/git" = {pkgs, ...}: {
    programs.git = {
      enable = true;
      settings = {
        user.name = config.flake.meta.user.fullName;
        user.email = config.flake.meta.user.email;

        pull.rebase = false;

        merge.tool = "vimdiff";
        merge.conflictstyle = "diff3";
        mergetool.prompt = false;
      };
    };
  };
}
