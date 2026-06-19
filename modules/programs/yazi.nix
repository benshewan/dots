{...}: {
  flake.modules.homeManager."programs/yazi" = {
    pkgs,
    lib,
    ...
  }: let
    kdeconnect-send = pkgs.fetchFromGitHub {
      owner = "Deepak22903";
      repo = "kdeconnect-send.yazi";
      rev = "06674d12779bd7243793bb29cf0a5f1273467d3d";
      sha256 = "sha256-katk13VE8J/Gn7N2Ez30/Xq0ldBV3yP2kowA0qVWYEg=";
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
      rev = "eba191d9915cdca48333740290bb604400392ef6";
      sha256 = "sha256-5Etw2bKTfhWHBXkIR6VZsbEbCN079QfIGLnQEYiR7Lw=";
    };

    sshfs = pkgs.fetchFromGitHub {
      owner = "uhs-robert";
      repo = "sshfs.yazi";
      rev = "a8b8903c0da5a4febe91713108a9b0c8a2749475";
      sha256 = "sha256-RYZ0wFkYfR/TfYntRipNPvpSl4gvtmNukLBQONRk1jU=";
    };
    # broken
    # f3d-preview = pkgs.fetchFromGitHub {
    #   owner = "christopher-nies";
    #   repo = "f3d-preview.yazi";
    #   rev = "76d115d94280828a2116aab3a46e43538f291331";
    #   sha256 = "sha256-pfvmjQw8m/0yUdCK+TW0mvZDWAfyx1skmPjvWSTvk00=";
    # };
  in {
    home.packages = with pkgs; [
      trash-cli
      ouch
      # f3d
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
          # ---- f3d-preview plugin ----
          # {
          #   url = "*.{3mf,obj,pts,ply,stl,step,stp}";
          #   run = "f3d-preview";
          # }
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
            url = "*.docx";
            run = "office";
          }
        ];

        plugin.prepend_previewers = [
          # ---- f3d-preview plugin ----
          # {
          #   url = "*.{3mf,obj,pts,ply,stl,step,stp}";
          #   run = "f3d-preview";
          # }
          # {
          #   url = "*.md";
          #   run = ''piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} -w=$w -s=dark "$1"'';
          # }
          # {
          #   url = "*.json";
          #   run = ''piper -- ${lib.getExe pkgs.jq} -C . "$1"'';
          # }

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
            url = "*.docx";
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

      plugins = {
        inherit (pkgs.yaziPlugins) vcs-files piper smart-filter git wl-clipboard mount recycle-bin ouch; # Nix Pkgs
        inherit kdeconnect-send office open-with-cmd sshfs; # Git (local defs)
      };
    };
  };
}
