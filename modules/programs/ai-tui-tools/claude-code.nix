_: {
  flake.modules.homeManager."programs/claude-code" = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs; [];
    programs.claude-code = {
      enable = true;
      mcpServers = {
        nixos = {
          command = "nix";
          args = ["run" "github:utensils/mcp-nixos" "--"];
        };
      };
    };
  };
}
