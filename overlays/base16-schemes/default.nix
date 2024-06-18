{...}: final: prev: let
  src = prev.fetchFromGitHub {
    owner = "tinted-theming";
    repo = "schemes";
    rev = "abcf2a055ae69f1bf047463332f83db3125aa8a5";
    sha256 = "sha256-wcotm0Ek2ISn8iJBzEujJQdcPLKWrPAOZ/dS/DLKafw=";
  };
in {
  # version in nixpkgs is quite out of date
  base16-schemes = prev.base16-schemes.overrideAttrs (oldAttrs: {
    inherit src;
  });
}
