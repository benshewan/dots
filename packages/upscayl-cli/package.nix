{
  lib,
  pkgs ? import <nixpkgs> {},
}:
pkgs.buildGoModule {
  pname = "upscayl-cli";
  version = "0.0.7";

  src = pkgs.fetchFromGitHub {
    owner = "yashschandra";
    repo = "upscayl-cli";
    rev = "v0.0.7";
    hash = "sha256-7s7/u4rbNKV6Cb3iYt67b7LJUR/vgVR4S0Or+qA24hc=";
  };

  vendorHash = "sha256-m5mBubfbXXqXKsygF5j7cHEY+bXhAMcXUts5KBKoLzM=";

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "A command line tool to run Upscayl on a server or a terminal (without GUI)";
    homepage = "https://github.com/yashschandra/upscayl-cli";
    license = licenses.mit;
    maintainers = with maintainers; [benshewan];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
