{inputs, ...}: final: prev: let
  awesome-vivaldi = prev.fetchFromGitHub {
    owner = "PaRr0tBoY";
    repo = "Awesome-Vivaldi";
    rev = "be4fc102722c88d189162092b2a80d4371f68fb7";
    sha256 = "sha256-Fsh4Dc4iPc8Sq0fXxYgjW4nLEnkS8Dnc0deKU0jJWUU=";
  };

  vivaldi-window = prev.writeText "window.html" ''
    <!-- Vivaldi window document -->
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8" />
      <title>Vivaldi</title>
      <link rel="stylesheet" href="style/common.css" />
      <link rel="stylesheet" href="chrome://vivaldi-data/css-mods/css" />
    </head>

    <body>
    <script src="mainbar.js"></script>
    <script src="monochromeIcons.js"></script>
    <script src="ybAddressBar.js"></script>
    <script src="mdNotes.js"></script>
    <script src="globalMediaControls.js"></script>
    <script src="autoHidePanel.js"></script>
     <!-- <script src="dialogTab.js"></script> -->
    <script src="feedIcon.js"></script>
    <script src="collapseKeyboardSettings.js"></script>
    <script src="accentMod.js"></script>
    <script src="importExportCommandChains.js"></script>
    </body>

    </html>
  '';
in {
  vivaldi = prev.vivaldi.overrideAttrs (oldAttrs: {
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        cd $out/opt/vivaldi/resources/vivaldi
        find ${awesome-vivaldi}/Javascripts -type f -exec cp {} ./. \;
        cp ${vivaldi-window} ./window.html
      '';
  });
}
