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
          ui = {
              theme = "stylix",
          },
          -- agent.rtk defaults to true and turns on once rtk is installed
          -- (see home.packages); set it to false to disable rewriting.
      })
    '';
  };
}
