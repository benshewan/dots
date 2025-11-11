{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.yazi;

  inherit (pkgs.stdenv) isDarwin isLinux;

  kdeconnect-send = pkgs.fetchFromGitHub {
    owner = "Deepak22903";
    repo = "kdeconnect-send.yazi";
    rev = "5757a65900d5439f7526e74d908b8205cb288a7e";
    sha256 = "sha256-xza+TXFGEqkPDVT2er5iisVd9QdGwJNKiUcu7Mjpeug=";
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
    rev = "433cf301c36882c31032d3280ab0c94825fc5e9f";
    sha256 = "sha256-QazKfNEPFdkHwMrH4D+VMwj8fGXM8KHDdSvm1tik3dQ=";
  };

  gvfs = pkgs.fetchFromGitHub {
    owner = "boydaihungst";
    repo = "gvfs.yazi";
    rev = "6db0c605ff4ccc9ef59613773aecbacc6fb93c9c";
    sha256 = "sha256-0W1nQ8MJ+BgPyKcn+oDzntX9BXplJEyl8UjsHWCHrE8=";
  };

  sshfs = pkgs.fetchFromGitHub {
    owner = "uhs-robert";
    repo = "sshfs.yazi";
    rev = "2728b14da2dff86b93aed9e04c45c60d5a06bdcd";
    sha256 = "sha256-KYO5h+yl2kpzWFt8OyGkfvW/I6XsSv4E/wB7PrgD6AA=";
  };

  compress = pkgs.fetchFromGitHub {
    owner = "KKV9";
    repo = "compress.yazi";
    rev = "c2646395394f22b6c40bff64dc4c8c922d210570";
    sha256 = "sha256-qAuMD4YojLfVaywurk5uHLywRRF77U2F7ql+gR8B/lo=";
  };
in {
  options.night-sky.programs.yazi = {
    enable = lib.mkEnableOption "yazi";
  };

  config = lib.mkIf cfg.enable {
    # should modify "office" directly instead
    home.packages = with pkgs; [
      libreoffice-fresh
    ];
    programs.yazi = {
      enable = true;
      package = pkgs.yazi.override {_7zz = pkgs._7zz-rar;};
      enableFishIntegration = true;
      settings = {
        # kdeconnect-send = {
        #   auto-select-single = true;
        # };
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
        plugin.prepend_previewers = let
          rich = lib.getExe pkgs.rich-cli;
        in [
          # {
          #   name = "*.csv";
          #   run = ''piper -- ${lib.getExe pkgs.csvlens} --color-columns "$1"'';
          # }
          # {
          #   name = "*.tsv";
          #   run = ''piper -- ${lib.getExe pkgs.csvlens} -t --color-columns'';
          # }
          {
            url = "*.md";
            run = ''piper -- CLICOLOR_FORCE=1 ${pkgs.glow} -w=$w -s=dark "$1"'';
          }

          {
            name = "*.rst";
            run = ''piper -- ${rich} -j --left --panel=rounded --guides --line-numbers --force-terminal "$1"'';
          } # for restructured text (.rst) files
          {
            name = "*.ipynb";
            run = ''piper -- ${rich} -j --left --panel=rounded --guides --line-numbers --force-terminal "$1"'';
          } # for jupyter notebooks (.ipynb)
          {
            name = "*.json";
            run = ''piper -- ${rich} -j --left --panel=rounded --guides --line-numbers --force-terminal "$1"'';
          } # for json (.json) files
          #    { name = "*.lang_type", run = "rich-preview"} # for particular language files eg. .py, .go., .lua, etc.

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

        # opener = {
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
        # };
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
        {
          on = ["M" "m"];
          run = "plugin gvfs -- select-then-mount";
          desc = "Select device then mount";
        }
        {
          on = ["M" "u"];
          run = "plugin gvfs -- select-then-unmount --eject";
          desc = "Select device then eject";
        }
        {
          on = ["M" "a"];
          run = "plugin gvfs -- add-mount";
          desc = "Add a GVFS mount URI";
        }
        {
          on = ["M" "r"];
          run = "plugin gvfs -- remove-mount";
          desc = "Remove a GVFS mount URI";
        }
        # {
        #   on = ["M" "s"];
        #   run = "plugin sshfs -- menu";
        #   desc = "Open SSHFS options";
        # }
        {
          on = ["c" "a" "a"];
          run = "plugin compress";
          desc = "Archive selected files";
        }
        {
          on = ["c" "a" "p"];
          run = "plugin compress -p";
          desc = "Archive selected files (password)";
        }
        {
          on = ["c" "a" "h"];
          run = "plugin compress -ph";
          desc = "Archive selected files (password+header)";
        }
        {
          on = ["c" "a" "l"];
          run = "plugin compress -l";
          desc = "Archive selected files (compression level)";
        }
        {
          on = ["c" "a" "u"];
          run = "plugin compress -phl";
          desc = "Archive selected files (password+header+level)";
        }
      ];

      initLua =
        ''
          require("git"):setup()
          require("sshfs"):setup()
        ''
        # gvfs only exists on linux
        + lib.optionalString isLinux ''
          require("gvfs"):setup({
            input_position = { "center", y = 0, w = 60 },
            password_vault = "keyring",
            save_password_autoconfirm = true,
          })
        '';

      plugins = with pkgs.yaziPlugins;
        {
          inherit vcs-files piper smart-filter git wl-clipboard;
          inherit kdeconnect-send office open-with-cmd sshfs compress;
        }
        // lib.optionalAttrs isLinux {
          inherit gvfs;
        };
    };
  };
}
