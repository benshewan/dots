{
  outputs,
  inputs,
  ...
}: {
  imports = [
    ./programs
    ./themes
  ];
  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
    inputs.nur.overlay
  ];
}
