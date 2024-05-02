{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nixvim.homeManagerModules.nixvim];

  # home.packages = [pkgs.neovim];

  programs.nixvim = {
    enable = true;
  };

  programs.nixvim.plugins.auto-save = {
    enable = true;
    enableAutoSave = true;
  };

  # programs.nixvim.plugins.airline = {
  #   enable = true;
  #   powerline = true;
  # };

  programs.nixvim.plugins.lsp = {
    enable = true;
    servers = {
      nil_ls.enable = true;
      tsserver.enable = true;
      html.enable = true;
    };
  };

  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      nixGrammars = true;
      indent = true;
    };
    treesitter-context.enable = true;
    rainbow-delimiters.enable = true;
  };

  programs.nixvim.plugins.gitsigns = {
    enable = true;
    settings = {
      current_line_blame = true;
    };
  };

  programs.nixvim.plugins.nvim-tree = {
    enable = true;
    openOnSetupFile = true;
    autoReloadOnWrite = true;
  };

  programs.nixvim.plugins.toggleterm = {
    enable = true;
    settings = {
      open_mapping = "[[<C-t>]]";
      direction = "horizontal";
    };
  };
}
