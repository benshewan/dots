{
  outputs,
  inputs,
  ...
}: {
  imports = [
    ./packages.nix
    ./programs
  ];
  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
    inputs.nur.overlay
  ];
}
