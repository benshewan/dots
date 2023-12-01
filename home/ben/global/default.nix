{outputs, ...}: {
  imports =
    [
      ./programs
      "${outputs.flake-path}/shared/hm"
    ]
    ++ map (x: "${outputs.flake-path}/shared/hm/programs/" + x) [
      "firefox"
      "kitty"
      "fish"
      "vscode"
      "spotify"
      # "virt-manager"
    ];
}
