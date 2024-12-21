{...}: {
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      # Layout
      layout = "bsp";
      window_placement = "second_child";

      # Mouse
      focus_follows_mouse = "autoraise";
      mouse_follows_focus = "on";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";

      # Style
      window_shadow = "float";
      window_opacity = "off";
      top_padding = 36;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
    };
  };
}
