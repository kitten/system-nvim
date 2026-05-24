# See: https://github.com/nix-community/nixvim/blob/3a66c8a33001d8bd79388c6b15eb1039f43f4192/lib/types.nix
{ lib, ... }:

with lib;
let
  mkRaw =
    r:
    if r == null || r == "" then
      null
    else if isString r then
      { __raw = r; }
    else if types.isRawType r then
      r
    else
      throw "mkRaw: invalid input: ${generators.toPretty { multiline = false; } r}";

  mkStrLuaType =
    description:
    mkOptionType {
      name = "strLua";
      inherit description;
      descriptionClass = "noun";
      check = v: isString v || types.rawLua.check v;
      merge =
        loc: defs:
        pipe defs [
          # Coerce strings to rawLua
          # TODO: consider deprecating this behaviour
          (map (def: def // { value = mkRaw def.value; }))
          (options.mergeEqualOption loc)
        ];
    };

  isRawType = v: isString (v.__raw or null);
in
rec {
  rawLua = mkOptionType {
    name = "rawLua";
    description = "raw lua code";
    descriptionClass = "noun";
    merge = options.mergeEqualOption;
    check = v: isRawType v || lua.isInline v || v ? __empty;
  };

  strLua = mkStrLuaType "lua code string";
  strLuaFn = mkStrLuaType "lua function string";

  submoduleOpts = options: types.submodule { inherit options; };

  mode =
    let
      modeEnum = types.enum [
        "" # normal, visual, select, and operator-pending (same as plain ':map')
        "n" # normal
        "!" # insert and command-line
        "i" # insert
        "c" # command
        "v" # visual and select
        "x" # visual only
        "s" # select
        "o" # operator-pending
        "t" # terminal
        "l" # insert, command-line and lang-arg
        "!a" # abbreviation in insert and command-line
        "ia" # abbreviation in insert
        "ca" # abbreviation in command
      ];
    in
    types.either modeEnum (types.listOf modeEnum)
    // {
      description = "a mode or list of modes";
      descriptionClass = "conjunction";
    };

  keymapOptions = types.submodule {
    options = {
      silent = mkOption {
        default = true;
        type = types.bool;
      };
      nowait = mkOption {
        default = false;
        type = types.bool;
      };
      script = mkOption {
        default = false;
        type = types.bool;
      };
      expr = mkOption {
        default = false;
        type = types.bool;
      };
      unique = mkOption {
        default = false;
        type = types.bool;
      };
      noremap = mkOption {
        default = true;
        type = types.bool;
      };
      remap = mkOption {
        default = false;
        type = types.bool;
      };
      desc = mkOption {
        default = null;
        type = types.nullOr types.str;
      };
      buffer = mkOption {
        default = null;
        type = types.nullOr (types.either types.bool types.int);
      };
    };
  };

  autocmd = types.submodule {
    options = {
      event = mkOption {
        type = types.either types.str (types.listOf types.str);
      };
      pattern = mkOption {
        default = null;
        type = types.nullOr (types.either types.str (types.listOf types.str));
      };
      group = mkOption {
        default = null;
        type = types.nullOr (types.either types.str types.int);
      };
      callback = mkOption {
        default = null;
        type = types.nullOr rawLua;
      };
      command = mkOption {
        default = null;
        type = types.nullOr types.str;
      };
      desc = mkOption {
        default = null;
        type = types.nullOr types.str;
      };
      buffer = mkOption {
        default = null;
        type = types.nullOr (types.either types.bool types.int);
      };
      once = mkOption {
        default = false;
        type = types.bool;
      };
      nested = mkOption {
        default = false;
        type = types.bool;
      };
    };
  };

  keymap = types.submodule {
    options = {
      mode = mkOption {
        default = "";
        type = mode;
        example = "n";
      };
      key = mkOption {
        type = types.str;
        description = "The key combo to map";
        example = "<C-x>";
      };
      action = mkOption {
        type = types.either rawLua types.str;
        description = "The action to execute.";
        apply = v: if options.lua.isDefined or false && config.lua then lib.nixvim.mkRaw v else v;
      };
      options = mkOption {
        default = { };
        type = keymapOptions;
      };
    };
  };
}
