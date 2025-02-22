{ pkgs, lib, config, plugins, inputs, ... }:

with lib;
let
  flake = inputs.nvim-treesitter-refactor;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.treesitter-refactor;
in {
  options.treesitter-refactor = let
    configType = types.submoduleOpts {
      highlight_definitions = types.submoduleOpts {
        enable = mkOption {
          default = true;
          type = types.bool;
        };
      };

      smart_rename = types.submoduleOpts {
        enable = mkOption {
          default = false;
          type = types.bool;
        };

        keymaps = mkOption {
          default = null;
          type = types.nullOr (types.attrsOf types.str);
        };
      };
    };
  in {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    config = mkOption {
      default = { };
      type = configType;
    };
  };

  config.plugins.treesitter-refactor = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "nvim-treesitter-refactor";
    dependencies = [ plugins.treesitter ];
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-refactor";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.treesitter-refactor ];

    treesitter = {
      enable = true;
      config.extra.refactor = cfg.config;
    };
  };
}
