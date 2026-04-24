{...}: {
  flake.modules.homeManager."programs/yazi" = {
    pkgs,
    lib,
    ...
  }: let
    kdeconnect-send = pkgs.fetchFromGitHub {
      owner = "Deepak22903";
      repo = "kdeconnect-send.yazi";
      rev = "8a6936b8d488eea43ee3910745b26fdfdbb2efbc";
      sha256 = "sha256-Ei29Sey0wVKglT8OLd3zmOPxj5xEnpWpSvqoICuXKRo=";
    };

    office = pkgs.fetchFromGitHub {
      owner = "macydnah";
      repo = "office.yazi";
      rev = "41ebef8be9dded98b5179e8af65be71b30a1ac4d";
      sha256 = "sha256-QFto48D+Z8qHl7LHoDDprvr5mIJY8E7j37cUpRjKdNk=";
    };

    open-with-cmd = pkgs.fetchFromGitHub {
      owner = "Ape";
      repo = "open-with-cmd.yazi";
      rev = "e3d430f8b12cb314a1d5744bcf8f76dd56b071e7";
      sha256 = "sha256-vN7zQeGuYN8TPKlA/6+SNFTVsA607z1DJPKXlNFJ9YM=";
    };

    sshfs = pkgs.fetchFromGitHub {
      owner = "uhs-robert";
      repo = "sshfs.yazi";
      rev = "2728b14da2dff86b93aed9e04c45c60d5a06bdcd";
      sha256 = "sha256-KYO5h+yl2kpzWFt8OyGkfvW/I6XsSv4E/wB7PrgD6AA=";
    };
    f3d-preview = pkgs.fetchFromGitHub {
      owner = "Ruudjhuu";
      repo = "f3d-preview.yazi";
      rev = "76d115d94280828a2116aab3a46e43538f291331";
      sha256 = "sha256-katk13VE8J/Gn7N2Ez30/Xq0ldBV3yP2kowA0qVWYEg=";
    };
  in {
    home.packages = with pkgs; [
      trash-cli
      ouch
      f3d
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
            id = "git";
            name = "*";
            run = "git";
          }
          {
            id = "git";
            name = "*/";
            run = "git";
          }
        ];

        plugin.prepend_preloaders = [
          # ---- f3d-preview plugin ----
          {
            url = "*.{3mf,obj,pts,ply,stl,step,stp}";
            run = "f3d-preview";
          }
          # Office Documents
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
            name = "*.docx";
            run = "office";
          }
        ];

        plugin.prepend_previewers = [
          # ---- f3d-preview plugin ----
          {
            url = "*.{3mf,obj,pts,ply,stl,step,stp}";
            run = "f3d-preview";
          }
          {
            url = "*.md";
            run = ''piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} -w=$w -s=dark "$1"'';
          }
          {
            name = "*.json";
            run = ''piper -- ${lib.getExe pkgs.jq} -C . "$1"'';
          }

          # Office Documents
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
            name = "*.docx";
            run = "office";
          }
        ];

        opener = {
          extract = [
            # ---- ouch zip compression plugin ----
            {
              run = ''${lib.getExe pkgs.ouch} d -y "$@"'';
              desc = "Extract here with ouch";
              for = "unix";
            }
          ];
          #   play = [
          #     {
          #       run = ''${lib.getExe pkgs.mpv} "$@"'';
          #       desc = "Play with MPV";
          #       orphan = true;
          #     }
          #   ];
          #   edit = [
          #     {
          #       run = ''${lib.getExe pkgs.kdePackages.kate} "$@"'';
          #       desc = "Edit with Kate";
          #       orphan = true;
          #     }
          #   ];
          #   office = [
          #     {
          #       run = ''${lib.getExe pkgs.libreoffice-fresh} "$@"'';
          #       desc = "Open with Office";
          #       orphan = true;
          #     }
          #   ];
        };
        # open.prepend_rules = [
        #   {
        #     name = "*";
        #     use = "edit";
        #   }
        # ];
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
        {
          run = "plugin smart-filter";
          on = ["F"];
          desc = "Smart filter";
        }
        {
          on = ["<C-y>"];
          run = "plugin wl-clipboard";
          desc = "Copy to clipboard";
        }
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

        # ---- recycle bin plugin ----
        {
          on = ["R"];
          run = "plugin recycle-bin";
          desc = "Open Recycle Bin menu";
        }

        # ---- ouch compression plugin ----
        {
          on = ["C"];
          run = "plugin ouch";
          desc = "Compress with ouch";
        }
        # ---- VCS plugin ----
        {
          on = ["G" "c"];
          run = "plugin vcs-files";
          desc = "Show Git file changes";
        }
      ];

      initLua = ''
        require("git"):setup {
          -- Order of status signs showing in the linemode
          order = 1500,
        }
        require("sshfs"):setup()
        require("recycle-bin"):setup()
      '';

      plugins = with pkgs.yaziPlugins; {
        inherit vcs-files piper smart-filter git wl-clipboard mount recycle-bin ouch; # Nix Pkgs
        inherit kdeconnect-send office open-with-cmd sshfs f3d-preview; # Git
      };
    };
  };
}
