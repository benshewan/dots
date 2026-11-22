{...}: {
  flake.modules.homeManager."window-managers/mangowm" = {...}: {
    wayland.windowManager.mango.settings = {
      window_rule = [
        # Firefox PIP
        "title:Picture-in-Picture,app_id:firefox.*,is_floating:1,no_animation:1,width:600,height:338,offset_x:100,offset_y:-100,no_border:1"
      ];
    };
  };
}
