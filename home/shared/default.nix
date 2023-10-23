{
  outputs,
  inputs,
  ...
}: {
  imports =
    [
      ./programs
      ./themes
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);
  nixpkgs.overlays = builtins.attrValues outputs.overlays ++ [inputs.nur.overlay];
}
