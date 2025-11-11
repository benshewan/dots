{
  pkgs,
  lib,
  ...
}: let
  version = "1.0.7";
in
  pkgs.buildGoModule {
    pname = "sysc-greet";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "Nomadcxx";
      repo = "sysc-greet";
      rev = "b1ceeb20ed09581f6ff9f3dce67daca56b57ebd1";
      # This sha256 is for the source code archive, which is correct
      sha256 = "sha256-yrAHWPdIKoAdydfJ6VIES5JnNYQpmbiEnAIGoQ8T1/A=";
    };

    # This is the hash for the vendored Go dependencies.
    # You will need to update this placeholder hash.
    # See the instructions below.
    vendorHash = "sha256-n/WQaEWYPlVZs1xNOER1tx5I6FwoU0IahZFZZGD4saA=";

    # Tell buildGoModule which package to build, as the root is not a main package
    subPackages = ["cmd/sysc-greet"];

    # The installPhase is handled automatically by buildGoModule.
    # It will place the 'sysc-greet' binary in $out/bin/

    # buildGoModule also includes `go` in nativeBuildInputs automatically.
    # Your original buildInputs was empty, so this is fine.

    postInstall = ''
      # This hook runs *after* the binary is installed to $out/bin/
      # We now copy all the assets the greeter needs.

      # 1. Install assets
      mkdir -p $out/share/sysc-greet
      cp -r $src/ascii_configs $out/share/sysc-greet/
      cp -r $src/fonts $out/share/sysc-greet/
      cp -r $src/wallpapers $out/share/sysc-greet/

      # 2. Install config templates
      # We put them in a known place so our NixOS module can find them.
      mkdir -p $out/share/sysc-greet/configs
      cp $src/config/kitty-greeter.conf $out/share/sysc-greet/configs/
      cp $src/config/niri-greeter-config.kdl $out/share/sysc-greet/configs/
      cp $src/config/hyprland-greeter-config.conf $out/share/sysc-greet/configs/
      cp $src/config/sway-greeter-config $out/share/sysc-greet/configs/
    '';

    meta = with lib; {
      description = "A graphical console greeter for greetd, written in Go with the Bubble Tea framework.";
      homepage = "https://github.com/Nomadcxx/sysc-greet";
      license = licenses.free;
      platforms = platforms.linux;
      # You had maintainers = [ ... ], but it's not defined in this scope.
      # If you are in nixpkgs, this is fine, otherwise you might need to remove or define it.
      # For this file to be self-contained, I'll use lib.maintainers
      maintainers = with maintainers; [
        /*
        benshewan
        */
      ]; # Add maintainer name if available in context
    };
  }
