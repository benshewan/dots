{
  lib,
  config,
  ...
}: {
  config =
    (lib.mkIf (config.services.gnome.gnome-keyring.enable == true) {
      security.pam.services.login = {
        enableGnomeKeyring = true;
      };
    })
    // {
      security.pam.services.swaylock = {
        text = ''
          auth include login
        '';
      };
    };
}
