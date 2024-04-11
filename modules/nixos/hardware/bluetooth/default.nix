{pkgs, ...}: {
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez5-experimental;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = "true";
      };
    };
  };
}
