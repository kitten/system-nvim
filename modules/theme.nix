{
  pkgs,
  config,
  lib,
  modulesPath,
  ...
}:

with lib;
let
  cfg = config.theme;

  themeName = "system-theme";

  # Palette values are RRGGBB hex (no leading #); the codegen prefixes #.
  hexColorType = mkOptionType {
    name = "hex-color";
    descriptionClass = "noun";
    description = "RGB color in 'RRGGBB' hex format (no leading #)";
    check = x: isString x && builtins.match "[0-9A-Fa-f]{6}" x != null;
  };

  paletteType = types.attrsOf hexColorType;

  noneType = types.enum [ "NONE" ];

  # types.oneOf can't reliably disambiguate leaf attrset vs branch attrset,
  # so we lean on `anything` and detect leaves manually in the codegen.
  highlightsType = types.attrsOf types.anything;

  leafKeys = [
    "link"
    "fg"
    "bg"
    "sp"
    "blend"
    "bold"
    "italic"
    "underline"
    "undercurl"
    "underdouble"
    "underdotted"
    "underdashed"
    "strikethrough"
    "standout"
    "reverse"
    "default"
    "force"
  ];
  isLeaf = v: isAttrs v && (any (k: v.${k} or null != null) leafKeys);

  # `base` (and the legacy `_hi`) means "self at the current path"
  isSelfKey = k: k == "base" || k == "_hi";

  recurse =
    path: value:
    if isAttrs value && !(isLeaf value) then
      mapAttrsToList (
        name: child: recurse (if isSelfKey name then path else path ++ [ name ]) child
      ) value
    else
      { ${concatStrings path} = value; };

  flatten = attrs: foldl recursiveUpdate { } (lib.flatten (recurse [ ] attrs));

  hashed = v: if isString v && builtins.match "[0-9A-Fa-f]{6}" v != null then "#${v}" else v;

  ctermOf =
    v:
    if isString v && builtins.match "[0-9A-Fa-f]{6}" v != null then
      colors.hexToCterm v
    else
      lua.mkInline "'NONE'";

  emitForceClear = name: /* lua */ ''
    vim.api.nvim_set_hl(0, ${lua.toLua name}, { fg = 'NONE', bg = 'NONE', ctermfg = 'NONE', ctermbg = 'NONE', force = true })
  '';

  emitLeaf =
    name: hl:
    let
      drop = [ "force" ];
      keep = filterAttrs (k: v: !(elem k drop) && v != null) hl;
      withColors =
        keep
        // (
          (optionalAttrs (keep ? fg) {
            fg = hashed keep.fg;
            ctermfg = if isString keep.fg then ctermOf keep.fg else null;
          })
          // (optionalAttrs (keep ? bg) {
            bg = hashed keep.bg;
            ctermbg = if isString keep.bg then ctermOf keep.bg else null;
          })
          // (optionalAttrs (keep ? sp) { sp = hashed keep.sp; })
        );
      forceOn = optionalAttrs (hl.force or null == true) { force = true; };
    in
    /* lua */ ''
      vim.api.nvim_set_hl(0, ${lua.toLua name}, ${lua.toLua (withColors // forceOn)})
    '';

  emit =
    name: value:
    if value == "NONE" then
      emitForceClear name
    else if isString value then
      "vim.api.nvim_set_hl(0, ${lua.toLua name}, { link = ${lua.toLua value} })"
    else if
      (value.force or null) == true && (value.fg or null) == null && (value.bg or null) == null
    then
      emitForceClear name
    else if (value.link or null) != null then
      "vim.api.nvim_set_hl(0, ${lua.toLua name}, { link = ${lua.toLua value.link} })"
    else
      emitLeaf name value;

  toLuaHighlights = highlights: concatStringsSep "\n" (mapAttrsToList emit (flatten highlights));
in
{
  options.theme = {
    enable = mkEnableOption "theme & highlights";

    background = mkOption {
      default = "dark";
      type = types.enum [
        "dark"
        "light"
      ];
    };

    palette = mkOption {
      default = import (modulesPath + "/../palettes/default.nix");
      type = paletteType;
      description = "Name → RRGGBB hex string.";
    };

    highlights = mkOption {
      default = { };
      type = highlightsType;
    };
  };

  config.nvim = mkIf cfg.enable {
    plugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = themeName;
        src = pkgs.writeTextFile {
          name = "${themeName}.lua";
          destination = "/colors/${themeName}.lua";
          text = /* lua */ ''
            if vim.g.colors_name then
              vim.cmd('hi clear')
            end
            if vim.fn.exists('syntax_on') then
              vim.cmd('syntax reset')
            end

            vim.o.background = '${cfg.background}'
            vim.g.colors_name = '${themeName}'
            vim.o.termguicolors = true

            ${toLuaHighlights cfg.highlights}
          '';
        };
      })
    ];

    luaInit = /* lua */ ''
      vim.cmd('colorscheme ${themeName}')
    '';
  };
}
