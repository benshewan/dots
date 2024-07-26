{pkgs, ...}: {
  services = {
    printing.enable = true;
    printing.drivers = with pkgs; [foomatic-db-ppds-withNonfreeDb gutenprint hplip splix ptouch-driver];
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
