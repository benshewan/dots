{pkgs, ...}: {
  services = {
    printing.enable = true;
    printing.drivers = [pkgs.foomatic-db-ppds-withNonfreeDb];
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
