_: {
  flake.modules.homeManager."programs/chromium" = {
    pkgs,
    config,
    ...
  }: {
    programs.chromium = {
      enable = true;
      extensions = [
        {id = "ddkjiahejlhfcafbddmgiahcphecmpfh";} # uBlock Origin Lite
        {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
        {id = "gbmdgpbipfallnflgajpaliibnhdgobh";} # JSON Viewer
        {id = "lmhkpmbekcpmknklioeibfkpmmfibljd";} # Redux Dev Tools
        {id = "fmkadmapgofadopljbjfkapdkoienihi";} # React Dev Tools
      ];
    };
  };
}
