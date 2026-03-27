{lib, ...}: final: prev: {
  chameleon-cli = prev.chameleon-cli.overrideAttrs (old: {
    version = "2.1.0-unstable-2026-03-20";
    src = prev.fetchFromGitHub {
      owner = "RfidResearchGroup";
      repo = "ChameleonUltra";
      rev = "e5d615d512e3afa7791117bd4a892b0b2c8e3600";
      sparseCheckout = ["software"];
      hash = "sha256-CP2flVLYR4nOYD2HLKc3OhJZ8q1hs0QwMEAzWFy7A6g=";
    };
    sourceRoot = "source/software";
  });
}
