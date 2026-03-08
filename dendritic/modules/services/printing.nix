{config, ...}: {
  flake.modules.nixos."services/printing" = {pkgs, ...}: {
    # For network auto discovery
    imports = config.flake.lib.resolve ["services/avahi"];

    # Setup CUPS
    services.printing = {
      enable = true;
      drivers = with pkgs; [foomatic-db-ppds-withNonfreeDb gutenprint hplip splix ptouch-driver];
    };
    # Allow configuring printers without root password
    users.users.${config.flake.meta.user.username}.extraGroups = ["lpadmin"];

    # for usb auto discovery
    services.ipp-usb.enable = true;
  };
}
