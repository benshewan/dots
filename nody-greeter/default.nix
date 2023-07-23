{ stdenv,
  fetchFromGithub
  nodejs_16,
  python311,
  ... 
  }:

stdenv.mkDerivation {
  name = "nody-greeter";
  version = "v1.5.2";

  src = fetchFromGithub (finalAttrs: {
    owner = "JezerM";
    repo = "nody-greeter";
    rev = "refs/tags/${finalAttrs.version}";
    sha256 = "126i0aw3gp1k9lgq1r8m9c6syqq8pz42hw9d394pvjd3x5q19r7l";
  });

  buildInputs = [ nodejs_16 python311 ];
}