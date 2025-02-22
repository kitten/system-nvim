{ pkgs, config, lib, ... }:

with lib;
let
  themeName = "system-theme";

  specialColorType = types.enum [ "NONE" ];

  hexColorType = mkOptionType {
    name = "hex-color";
    descriptionClass = "noun";
    description = "RGB color in hex format";
    check = x: isString x && builtins.match "^#[0-9A-Fa-f]{6}$" x != null;
  };

  highlightType = types.submodule {
    options = let
      boolOption = mkOption {
        default = null;
        type = types.nullOr types.bool;
      };
    in {
      fg = mkOption {
        default = "NONE";
        type = types.nullOr (types.either hexColorType specialColorType);
      };
      bg = mkOption {
        default = "NONE";
        type = types.nullOr (types.either hexColorType specialColorType);
      };
      sp = mkOption {
        default = null;
        type = types.nullOr (types.either hexColorType specialColorType);
      };
      blend = mkOption {
        default = null;
        type = types.nullOr (types.ints.between 0 100);
      };
      bold = boolOption;
      italic = boolOption;
      underline = boolOption;
      undercurl = boolOption;
      underdouble = boolOption;
      underdotted = boolOption;
      underdashed = boolOption;
      strikethrough = boolOption;
      standout = boolOption;
      reverse = boolOption;
    };
  };

  highlightsType = let
    valueType = (types.oneOf [
      highlightType
      specialColorType
      types.str
      (types.attrsOf valueType)
    ]) // {
      description = "Neovim highlight value";
    };
  in types.attrsOf valueType;

  toLuaHighlights = let
    isHighlight = value: builtins.isAttrs value && builtins.hasAttr "fg" value && builtins.hasAttr "bg" value;
    recurse = path: value:
      if builtins.isAttrs value && !(isHighlight value) then
        mapAttrsToList
          (name: value: recurse (if name != "_hi" then path ++ [name] else []) value)
          value
      else { ${concatStrings path} = value; };
    flattenHighlightValue = { fg, bg, ... } @ hi: hi // {
      fg = if fg != "NONE" then fg else "NONE";
      bg = if bg != "NONE" then bg else "NONE";
      ctermfg = if fg != "NONE" then (colors.hexToCterm fg) else "NONE";
      ctermbg = if bg != "NONE" then (colors.hexToCterm bg) else "NONE";
    };
    fromHighlightValue = prop: value:
      if value == null then
        null
      else if builtins.isInt value then
        "${prop} = ${builtins.toString value}"
      else if builtins.isBool value then
        "${prop} = ${trivial.boolToString value}"
      else
        "${prop} = '${toString value}'";
    toFlatAttrs = attrs: foldl recursiveUpdate {} (flatten (recurse [] attrs));
    mapHlAttrs = value:
      builtins.filter (e: e != null) (mapAttrsToList fromHighlightValue (flattenHighlightValue value));
    toValue = name: value:
      if value == "NONE" then
        "vim.api.nvim_set_hl(0, '${name}', { fg = 'NONE', bg = 'NONE', ctermfg = 'NONE', ctermbg = 'NONE', nocombine = true, force = true })"
      else if builtins.isString value then
        "vim.api.nvim_set_hl(0, '${name}', { link = '${value}' })"
      else 
        "vim.api.nvim_set_hl(0, '${name}', { ${concatStringsSep ", " (mapHlAttrs value)} })";
  in colors: (concatStringsSep "\n" (mapAttrsToList toValue (toFlatAttrs colors)));
in {
  options.theme = mkOption {
    default = { };
    type = types.submodule {
      options = {
        enable = mkEnableOption "";
        background = mkOption {
          default = "dark";
          type = types.enum [ "dark" "light" ];
        };
        highlights = mkOption {
          default = { };
          type = highlightsType;
        };
      };
    };
  };

  config.nvim = mkIf config.theme.enable {
    plugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = themeName;
        src = pkgs.writeTextFile {
          name = "${themeName}.lua";
          destination = "/colors/${themeName}.lua";
          text = /*lua*/''
            if vim.g.colors_name then
              vim.cmd('hi clear')
            end
            if vim.fn.exists('syntax_on') then
              vim.cmd('syntax reset')
            end

            vim.o.background = '${config.theme.background}'
            vim.g.colors_name = '${themeName}'
            vim.o.termguicolors = true

            ${toLuaHighlights config.theme.highlights}
          '';
        };
      })
    ];

    luaInit = /*lua*/''
      vim.cmd('colorscheme ${themeName}')
    '';
  };
}
