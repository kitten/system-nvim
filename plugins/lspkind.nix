{ pkgs, lib, config, plugins, inputs, ... }:

with lib;
let
  flake = inputs.nvim-lspkind;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.lspkind;
in {
  options.lspkind = let
    configType = types.submoduleOpts {
      mode = mkOption {
        default = "symbol";
        type = types.enum [ "text" "text_symbol" "symbol_text" "symbol" ];
      };

      preset = mkOption {
        default = "default";
        type = types.enum [ "default" "codicons" ];
      };

      symbol_map = mkOption {
        default = null;
        type = types.nullOr (types.attrsOf types.str);
      };
    };
  in {
    enable = mkOption {
      default = true;
      type = types.bool;
    };

    config = mkOption {
      default = { };
      type = configType;
    };
  };

  config.plugins.lspkind = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "nvim-lspkind";
    nvimRequireCheck = [ "lspkind" ];
    meta.homepage = "https://github.com/onsails/lspkind-nvim/";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.lspkind ];

    luaInit = /*lua*/''
      require('lspkind').init(${lua.toLua cfg.config})
    '';
  };
}
