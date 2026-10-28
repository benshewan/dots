{
  inputs,
  config,
  ...
}: {
  flake-file.inputs = {
    nixvim.url = "github:nix-community/nixvim";
  };
  flake.modules.homeManager."programs/nvim" = {pkgs, ...}: {
    imports = [inputs.nixvim.homeModules.nixvim];

    programs.nixvim = {
      enable = true;
      clipboard.providers.wl-copy.enable = true;

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      # Lazy-loading provider for plugins
      # https://nix-community.github.io/nixvim/user-guide/lazy-loading.html
      plugins.lz-n.enable = true;

      plugins.yazi = {
        enable = true;
        # Don't load until :Yazi is first used (e.g. via <leader>- below)
        lazyLoad.settings.cmd = "Yazi";
      };

      plugins.hop = {
        enable = true;
        # hop sets no keymaps itself; this both creates the mapping and
        # lazy-loads hop the first time it is pressed
        lazyLoad.settings.keys = [
          {
            __unkeyed-1 = "s";
            __unkeyed-2.__raw = ''
              function()
                require('hop').hint_words()
              end
            '';
            desc = "Hop to word";
          }
        ];
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>-";
          action = "<cmd>Yazi<cr>";
          options.desc = "Open yazi at current file";
        }
      ];
    };
  };
}
