{inputs, ...}: {
  flake-file.inputs = {
    # maki pins an old rust-overlay whose lib uses the deprecated
    # stdenv.isLinux/isDarwin; follow a current one instead.
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    maki = {
      url = "github:tontinton/maki";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
  };

  flake.modules.homeManager."programs/maki" = {
    pkgs,
    ...
  }: {
    home.packages = [
      inputs.maki.packages.${pkgs.stdenv.hostPlatform.system}.default

      # rtk: maki's bash plugin rewrites commands through it (probes
      # `rtk --version` at runtime; on by default via agent.rtk). Optional:
      # without it on PATH maki just runs commands unrewritten.
      pkgs.rtk
    ];

    # Themes live in ./theme.nix, which merges into this same module.
    # Force-apply the stylix theme on every startup, overriding any
    # interactively-selected theme.
    home.file.".config/maki/init.lua".text = ''
      -- Managed by Nix. Extend this file with more maki.setup() options if needed.
      maki.setup({
          always_yolo = true,
          ui = {
              theme = "stylix",
          },
          plugins = {
              completion = { enabled = true },
            },
      })
      require("opencode_usage")
    '';

    # OpenCode Go usage HUD (./opencode_usage.lua). Needs fs_read for the key
    # in maki's auth dir, net as fallback, and run for the curl workaround
    # (maki.net.request deadlocks inside the plugin executor).
    home.file.".config/maki/lua/opencode_usage.lua".source = ./opencode_usage.lua;
    home.file.".config/maki/plugin.toml".text = ''
      min_maki_version = "0.4.12"

      [permissions]
      fs_read = true
      net = true
      run = true
    '';
  };
}
