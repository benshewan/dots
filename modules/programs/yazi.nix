{...}: {
  flake.modules.homeManager."programs/yazi" = {
    pkgs,
    lib,
    ...
  }: let
    open-with-cmd = pkgs.fetchFromGitHub {
      owner = "Ape";
      repo = "open-with-cmd.yazi";
      rev = "56705e2d378f8ab6c898981d90bddeb65ed4b748";
      sha256 = "sha256-VClpoa3T4uVrJzdGlWHpCnaWLY1Kdk5xIIDksibScpM=";
    };
  in {
    home.packages = with pkgs; [
      (ouch.override {enableUnfree = true;})
      # f3d

      # For the office plugin ----------------------------------------
      libreoffice
      xpdf
    ];

    programs.yazi = {
      enable = true;
      package = pkgs.yazi.override {_7zz = pkgs._7zz-rar;};
      enableFishIntegration = true;
      shellWrapperName = "yy";
      settings = {
        mgr = {
          sort_dir_first = true;
          sort_by = "mtime";
          sort_reverse = true;
          show_symlink = true;
          show_hidden = false; # can be toggled with "."
        };

        plugin.prepend_fetchers = [
          {
            url = "*";
            run = "git";
            group = "git";
          }
          {
            url = "*/";
            run = "git";
            group = "git";
          }
        ];

        plugin.prepend_preloaders = [
          # Office Documents ----------------------------------------
          {
            mime = "application/openxmlformats-officedocument.*";
            run = "office";
          }
          {
            mime = "application/oasis.opendocument.*";
            run = "office";
          }
          {
            mime = "application/ms-*";
            run = "office";
          }
          {
            mime = "application/msword";
            run = "office";
          }
          {
            url = "*.docx";
            run = "office";
          }
        ];

        plugin.prepend_previewers = [
          # Office Documents ----------------------------------------
          {
            mime = "application/openxmlformats-officedocument.*";
            run = "office";
          }
          {
            mime = "application/oasis.opendocument.*";
            run = "office";
          }
          {
            mime = "application/ms-*";
            run = "office";
          }
          {
            mime = "application/msword";
            run = "office";
          }
          {
            url = "*.docx";
            run = "office";
          }

          # Compressed Documents ----------------------------------------
          {
            mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
            run = "ouch --show-file-icons";
          }
        ];

        opener = {
          extract = [
            {
              run = ''${lib.getExe (pkgs.ouch.override {enableUnfree = true;})} d -y %s'';
              desc = "Extract here with ouch";
            }
          ];
          play = [
            {
              run = ''${lib.getExe pkgs.mpv} %s'';
              desc = "Play with MPV";
              orphan = true;
            }
          ];
        };
      };

      keymap.mgr.prepend_keymap = [
        {
          on = "<Esc>";
          run = "close";
          desc = "Cancel input";
        }
        {
          run = ''shell "$SHELL" --block'';
          on = ["!"];
          desc = "Open $SHELL here";
        }
        # ---- KDE connect plugin ----
        {
          run = "plugin kdeconnect-send";
          on = ["<C-s>"];
          desc = "Send selected files via KDE Connect";
        }
        # ---- Smart Filter plugin ----
        {
          run = "plugin smart-filter";
          on = ["F"];
          desc = "Smart filter";
        }
        # ---- clipboard plugin ----
        {
          on = ["<C-y>"];
          run = "plugin wl-clipboard";
          desc = "Copy to clipboard";
        }
        # ---- Open with command plugin ----
        {
          on = ["<C-o>"];
          run = "plugin open-with-cmd";
          desc = "Open with command";
        }
        # ---- mount plugin ----
        {
          on = ["M"];
          run = "plugin mount";
          desc = "Mount drive";
        }
        # ---- ouch plugin ----
        {
          on = ["c" "a"];
          run = "plugin ouch";
          desc = "Archive selected files";
        }
        # ---- easyjump plugin ----
        {
          on = ["i"];
          run = "plugin easyjump";
          desc = "easyjump";
        }
      ];

      initLua = ''
        require("easyjump"):setup()
        require("git"):setup {
          -- Order of status signs showing in the linemode
          order = 1500,
        }
        require("sshfs"):setup()
        require("kdeconnect-send"):setup({
            auto_select_single = true,
        })
      '';

      plugins = {
        inherit (pkgs.yaziPlugins) piper smart-filter git wl-clipboard mount sshfs office kdeconnect-send ouch easyjump; # Nix Pkgs
        inherit open-with-cmd; # Git (local defs)
      };
    };
  };
}
