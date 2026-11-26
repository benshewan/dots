{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside the NixOS
  # modules below, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  # NixOS side, not Home Manager: dumpcap needs a setcap wrapper to capture
  # without root, and that only exists through programs.wireshark (it also
  # creates the wireshark group the wrapper is gated on, and puts the
  # package on the system path).
  flake.modules.nixos."programs/wireshark" = {pkgs, ...}: {
    programs.wireshark = {
      enable = true;
      # nixpkgs defaults to the headless wireshark-cli; this repo is desktop
      # first, so pull the Qt GUI (it still ships dumpcap).
      package = pkgs.wireshark;
    };

    # The setcap wrapper is u+rx,g+x for group wireshark: membership is what
    # lets the user capture without root. Merges with the groups list in
    # modules/users.nix (plain list concatenation). NOTE: group membership is
    # evaluated at session start — a session that predates the first switch
    # with this module keeps the old groups and its children get EACCES from
    # the wrapper (observed on caelum: the audit capture failed until the
    # reboot). A live switch is not enough; re-login or reboot.
    users.users.${username}.extraGroups = ["wireshark"];
  };

  # Preservation companion for "programs/wireshark" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/wireshark" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username}.directories = [
      # Personal config dir (XDG since forever): preferences, recent +
      # recent_common (window/filter state), dfilter_history, colorfilters
      # and the capture-filter and display-filter profiles in profiles/.
      ".config/wireshark"
      # Personal Lua/extcap plugins (~/.local/lib/wireshark/plugins). Empty
      # until the user installs some, but anything dropped there is
      # hand-placed state, not regenerable.
      ".local/lib/wireshark"
    ];
  };
}
