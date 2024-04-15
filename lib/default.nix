{lib, ...}: {
  # recursiveAttrValues = let
  #   recuriveFunction = n:
  #     if builtins.typeOf n == "set"
  #     then lib.lists.flatten (lib.lists.forEach (builtins.attrValues n) (x: recuriveFunction x))
  #     else n;
  # in
  #   recuriveFunction;
}
