{inputs, ...}: {
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  flake.modules.nixos."programs/opencode2" = {...}: {
    nixpkgs.overlays = [inputs.llm-agents.overlays.shared-nixpkgs];
  };

  flake.modules.homeManager."programs/opencode2" = {pkgs, ...}: {
    home.packages = [pkgs.llm-agents.opencode2];
    # programs.opencode = {
    #   enable = true;
    #   package = pkgs.llm-agents.opencode2;
    #   settings = {
    #     autoupdate = false;
    #     share = "disabled";
    #     provider = {
    #       local = {
    #         npm = "@ai-sdk/openai-compatible";
    #         name = "Local AI";
    #         options = {
    #           baseURL = "http://192.168.2.39:8433/v1";
    #         };
    #         models = {
    #           "unsloth/gemma-4-E4B-it-GGUF:Q4_K_M" = {
    #             name = "Gemma 4 E4B";
    #             limit = {
    #               context = 65536;
    #               output = 65536;
    #             };
    #           };
    #         };
    #       };
    #     };
    #   };
    # };
  };
}
