# Maki theme: renders ~/.config/maki/themes/stylix.toml from the Stylix base16
# palette via writeTOML. Merged into the `programs/maki` module by flake-parts
# (like mcp.nix); self-disables on hosts without stylix — e.g. apus.
_: {
  flake.modules.homeManager."programs/maki" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    themeName = "stylix";

    # `config.lib` always exists in home-manager (lib.file.*), so the hasAttr
    # is safe to force everywhere; Nix's lazy `&&` only forces
    # config.stylix.enable where the module — and thus the option — exists.
    stylixActive = config.lib ? stylix && config.stylix.enable;

    base16 = config.lib.stylix.colors;
    inherit (base16) withHashtag;

    # Value of a base16 colour channel, e.g. `chan "base00" "rgb-r"` -> 29.
    chan = slot: channel: lib.toInt base16."${slot}-${channel}";

    # Zero-padded two-digit lowercase hex byte (Nix has no modulo operator).
    hexDigits = "0123456789abcdef";
    hexByte = n:
      lib.substring (n / 16) 1 hexDigits
      + lib.substring (n - (n / 16) * 16) 1 hexDigits;

    # Darken a base16 slot by num/denom (integer math), e.g. 88 100 = 88%.
    darken = slot: num: denom: let
      scale = channel: chan slot channel * num / denom;
    in "#${hexByte (scale "rgb-r")}${hexByte (scale "rgb-g")}${hexByte (scale "rgb-b")}";

    # A maki theme is `"<scope>" = { fg, bg, modifiers }` entries plus
    # [palette] and [ui] tables. writeTOML renders each scope as a table;
    # remarshal quotes dotted keys (["comment.block"]) so scope names stay
    # intact. `bg` values are a palette name or a hex colour.
    fg = color: {fg = color;};
    fgMod = color: modifiers: {
      fg = color;
      inherit modifiers;
    };
    bg = color: {bg = color;};
    fgBg = foreground: background: {
      fg = foreground;
      bg = background;
    };

    # -- palette ---------------------------------------------------------------
    # Standard base16 roles onto maki's palette names.
    palette = {
      background = withHashtag.base00;
      foreground = withHashtag.base05;
      comment = withHashtag.base03;
      cyan = withHashtag.base0C;
      green = withHashtag.base0B;
      orange = withHashtag.base09;
      pink = withHashtag.base0E;
      purple = withHashtag.base0E;
      red = withHashtag.base08;
      yellow = withHashtag.base0A;
      blue = withHashtag.base0D;
      brown = withHashtag.base0F;
      current_line = withHashtag.base01;
      selection = withHashtag.base02;
    };

    # -- syntax highlighting ---------------------------------------------------
    highlightGroups = [
      {
        "comment" = fg "comment";
        "comment.block" = fg "comment";
        "comment.block.documentation" = fg "comment";
        "comment.line" = fg "comment";
        "comment.line.documentation" = fg "comment";
      }
      {
        "constant" = fg "purple";
        "constant.builtin" = fg "purple";
        "constant.builtin.boolean" = fg "purple";
        "constant.character" = fg "cyan";
        "constant.character.escape" = fg "pink";
        "constant.macro" = fg "purple";
        "constant.numeric" = fg "purple";
        "constructor" = fg "purple";
      }
      {
        "error" = fg "red";
        "warning" = fg "yellow";
        "info" = fg "cyan";
        "hint" = fg "purple";
      }
      {
        "diff.delta" = fg "orange";
        "diff.minus" = fg "red";
        "diff.plus" = fg "green";
      }
      {
        "function" = fg "blue";
        "function.builtin" = fg "blue";
        "function.call" = fg "blue";
        "function.macro" = fg "purple";
        "function.method" = fg "blue";
      }
      {
        "keyword" = fg "pink";
        "keyword.control.conditional" = fg "pink";
        "keyword.control.exception" = fg "purple";
        "keyword.control.import" = fg "pink";
        "keyword.control.repeat" = fg "pink";
        "keyword.directive" = fg "green";
        "keyword.function" = fg "pink";
        "keyword.operator" = fg "pink";
        "keyword.return" = fg "pink";
        "keyword.storage" = fg "pink";
        "keyword.storage.modifier" = fg "pink";
        "keyword.storage.type" = fgMod "cyan" ["italic"];
      }
      {
        "label" = fg "cyan";
        "attribute" = fgMod "green" ["italic"];
        "namespace" = fg "foreground";
        "annotation" = fg "foreground";
        "operator" = fg "pink";
      }
      {
        "markup.bold" = fgMod "orange" ["bold"];
        "markup.heading" = fgMod "purple" ["bold"];
        "markup.italic" = fgMod "yellow" ["italic"];
        "markup.link.text" = fg "pink";
        "markup.link.url" = fg "cyan";
        "markup.list" = fg "cyan";
        "markup.quote" = fgMod "yellow" ["italic"];
        "markup.raw" = fg "foreground";
        "markup.strikethrough" = {modifiers = ["crossed_out"];};
      }
      {
        "punctuation" = fg "foreground";
        "punctuation.bracket" = fg "foreground";
        "punctuation.delimiter" = fg "foreground";
        "punctuation.special" = fg "pink";
      }
      {
        "special" = fg "pink";
      }
      {
        "string" = fg "yellow";
        "string.regexp" = fg "red";
        "string.special" = fg "orange";
        "string.symbol" = fg "yellow";
      }
      {
        "tag" = fg "pink";
        "tag.attribute" = fg "purple";
        "tag.delimiter" = fg "foreground";
      }
      {
        "type" = fgMod "cyan" ["italic"];
        "type.builtin" = fg "cyan";
        "type.enum.variant" = fgMod "foreground" ["italic"];
      }
      {
        "variable" = fg "foreground";
        "variable.builtin" = fgMod "purple" ["italic"];
        "variable.other" = fg "foreground";
        "variable.other.member" = fg "foreground";
        "variable.parameter" = fgMod "orange" ["italic"];
      }
    ];

    # -- app chrome (maki's [ui] table) ---------------------------------------
    ui = {
      user = fg "cyan";
      assistant = fg "foreground";
      assistant_prefix = fg "pink";
      thinking = fgMod "comment" ["italic"];
      tool_bg = bg (darken "base00" 88 100);
      tool = fg "foreground";
      tool_path = fg "orange";
      tool_annotation = fg "comment";
      tool_prefix = fgMod "foreground" ["bold"];
      tool_success = fg "green";
      tool_error = fg "red";
      tool_dim = fg "comment";
      error = fg "red";
      status_dim = fg "comment";
      strikethrough = fgMod "comment" ["crossed_out"];
      plan_rule = fgMod "pink" ["bold"];
      code_block = fg "foreground";
      horizontal_rule = fg "comment";
      table_border = fg "comment";
      diff_old = bg (darken "base08" 35 100);
      diff_new = bg (darken "base0B" 35 100);
      diff_old_emphasis = bg (darken "base08" 50 100);
      diff_new_emphasis = bg (darken "base0B" 50 100);
      diff_line_nr = fg "comment";
      todo_completed = fg "green";
      todo_in_progress = fg "yellow";
      todo_pending = fg "comment";
      todo_cancelled = fgMod "red" ["crossed_out"];
      item_selected = fgBg "background" "purple";
      item = fg "cyan";
      item_desc = fg "comment";
      accent = fg "orange";
      panel_border = fg "purple";
      panel_title = fgMod "purple" ["bold"];
      cursor = fgBg "background" "foreground";
      keybind_key = fgMod "cyan" ["bold"];
      keybind_section = fgMod "purple" ["bold"];
      input_border = fg "comment";
      keybind_desc = fg "foreground";
      queue = fg "purple";
      plan_path = fgMod "orange" ["bold"];
      status_notice = fg "orange";
      status_retry_error = fg "red";
      status_retry_info = fg "comment";
      input_placeholder = fg "comment";
      queue_delete = fgMod "red" ["bold"];
      timestamp = fg "comment";
      spinner = fg "yellow";
      active = fg "cyan";
      progress_bar = fgBg "cyan" "background";
      shell_prefix = fgMod "yellow" ["bold"];
    };

    # mergeAttrs throws on a duplicate scope — one scope, one owner.
    theme =
      lib.foldl' lib.mergeAttrs {} highlightGroups
      // {inherit palette ui;};
  in
    lib.mkIf stylixActive {
      # Merges into maki.nix's modules.maki.setup option, so the core module
      # stays palette-agnostic.
      modules.maki.setup.ui.theme = themeName;

      home.file.".config/maki/themes/${themeName}.toml".source =
        pkgs.writers.writeTOML "maki-theme-${themeName}.toml" theme;
    };
}
