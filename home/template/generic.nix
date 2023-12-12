{
  outputs,
  pkgs,
  ...
}: {
  imports =
    [
      # Load in generic home manager configuration
      "${outputs.flake-path}/shared/hm"
    ]
    # Customized Ben-Brand packages
    ++ map (x: "${outputs.flake-path}/shared/hm/programs/" + x) [
      "firefox"
      "vscode"
      "spotify"
    ];

  # Programs
  home.packages = with pkgs; [
    #  any packages go here
  ];

  # Example program configuration
  # programs.java = {
  #   enable = true;
  #   package = pkgs.jdk17;
  # };

  # programs.git = {
  #   enable = true;
  #   userName = "Template User";
  #   userEmail = "template@gmail.com";
  #   extraConfig = {
  #     pull.rebase = false;
  #   };
  # };
}
