{inputs, ...}: {
  flake-file.inputs = {
    hyprsplit.url = "github:shezdy/hyprsplit";
    hyprsplit.inputs.nixpkgs.follows = "nixpkgs";
  };

  # DWM like per monitor workspaces: https://github.com/shezdy/hyprsplit
  flake.modules.homeManager."window-managers/hyprland" = {...}: {
    wayland.windowManager.hyprland = {
      extraLuaFiles = {
        # create a symlink to `.config/hypr/hyprsplit/init.lua`.
        "hyprsplit/init" = {
          autoLoad = false;
          content = builtins.readFile "${inputs.hyprsplit.hyprsplitlua}/share/hyprsplit/init.lua";
        };
        # Finally, use it directly in Lua.
        "hyprload" = {
          autoLoad = true;
          content = ''
            local hs = require("hyprsplit")
            hs.config({ num_workspaces = 10 })
            for i = 1, 10 do
                local key = i % 10 -- 10 maps to key 0
                hl.bind("SUPER + " .. key, hs.dsp.focus({ workspace = i }))
                hl.bind("SUPER + SHIFT + " .. key, hs.dsp.window.move({ workspace = i, follow = false }))
            end

            hl.bind("SUPER + " .. "g", hs.dsp.grab_rogue_windows())
            hl.bind("SUPER + " .. "d", hs.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" }))
          '';
        };
      };
    };
  };
}
