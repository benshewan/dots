_: {
  flake.modules.homeManager."programs/opencode" = {pkgs, ...}: {
    programs.opencode = {
      enable = true;
      settings = {
        autoupdate = false;
        share = "disabled";
        provider = {
          local = {
            npm = "@ai-sdk/openai-compatible";
            name = "Local AI";
            options = {
              baseURL = "http://192.168.2.39:8433/v1";
            };
            models = {
              "unsloth/gemma-4-E4B-it-GGUF:Q4_K_M" = {
                name = "Gemma 4 E4B";
                limit = {
                  context = 65536;
                  # input = 128000;
                  output = 65536;
                };
              };
            };
          };
        };
      };
    };
  };
}
