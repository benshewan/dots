{pkgs, ...}: {
  home.packages = with pkgs; [
    filebot # Media batch renamer
  ];

  #  Filebot license

  #  Can't find file for some reason
  # home.file.".local/share/filebot/data/.license".source = ./.license;
}
