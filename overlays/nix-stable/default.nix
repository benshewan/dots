{channels, ...}: final: _prev: {
  stable = import channels.nixpkgs-stable {
    system = final.system;
    config.allowUnfree = true;
  };
}
