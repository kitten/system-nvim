{ pkgs, lib, config, plugins, inputs, ... }:

with lib;
let
  flake = inputs.nvim-heirline;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.heirline;
in {
  options.heirline = let
    statuslineType = types.submoduleOpts {
      provider = mkOption {
        type = types.either types.rawLua types.str;
      };

      hl = mkOption {
        default = null;
        type = types.str;
      };

      condition = mkOption {
        default = null;
        type = types.nullOr types.rawLua;
      };

      init = mkOption {
        default = null;
        type = types.nullOr types.rawLua;
      };

      update = mkOption {
        default = null;
        type = types.nullOr types.rawLua;
      };

      flexible = mkOption {
        default = null;
        type = types.nullOr types.int;
      };

      fallthrough = mkOption {
        default = true;
        type = types.bool;
      };

      static = mkOption {
        default = { };
        type = types.attrsOf types.anything;
      };

      children = statuslineList;
    };

    statuslineList = mkOption {
      default = null;
      type = types.nullOr (types.listOf statuslineType);
      apply = let
        toStatusline = { children, ... } @ args: let
          statusline = (removeAttrs args [ "children" ]);
        in if children == null then statusline else [ statusline ] ++ children;
      in v: if v != null then map toStatusline v else null;
    };
  in {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    statusline = statuslineList;
    winbar = statuslineList;
    tabline = statuslineList;
    statuscolumn = statuslineList;
  };

  config.plugins.heirline = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "nvim-heirline";
    nvimRequireCheck = [ "heirline" ];
    meta.homepage = "https://github.com/rebelot/heirline.nvim/";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.heirline ];

    luaInit = /*lua*/''
      require("heirline").setup({
        statusline = ${lua.toLua cfg.statusline},
        winbar = ${lua.toLua cfg.winbar},
        tabline = ${lua.toLua cfg.tabline},
        statuscolumn = ${lua.toLua cfg.statuscolumn},
      })
    '';
  };
}
