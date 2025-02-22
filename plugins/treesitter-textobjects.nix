{ pkgs, lib, config, plugins, inputs, ... }:

with lib;
let
  flake = inputs.nvim-treesitter-textobjects;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.treesitter-textobjects;
in {
  options.treesitter-textobjects = let
    configType = types.submoduleOpts {
      select = types.submoduleOpts {
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

  config.plugins.treesitter-textobjects = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "nvim-treesitter-textobjects";
    dependencies = [ plugins.treesitter ];
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.treesitter-textobjects ];

    treesitter = {
      enable = true;
      config.extra.textobjects = cfg.config;
    };
  };
}
