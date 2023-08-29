{pkgs,...}:
{

home.packages = with pkgs; [
    filebot # Media batch renamer
  ];

   #  Filebot license
  home.file.".local/share/filebot/data/.license".source = ./.license;
}