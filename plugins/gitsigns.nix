{
  pkgs,
  lib,
  config,
  plugins,
  inputs,
  ...
}:

with lib;
let
  flake = inputs.nvim-gitsigns;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.gitsigns;

  signType = types.submoduleOpts {
    text = mkOption { type = types.str; };
  };

  configType = types.submoduleOpts {
    signcolumn = mkOption {
      default = true;
      type = types.bool;
    };
    numhl = mkOption {
      default = false;
      type = types.bool;
    };
    linehl = mkOption {
      default = false;
      type = types.bool;
    };
    word_diff = mkOption {
      default = false;
      type = types.bool;
    };
    current_line_blame = mkOption {
      default = false;
      type = types.bool;
    };

    signs = mkOption {
      default = { };
      type = types.attrsOf signType;
    };

    diff_opts = mkOption {
      default = null;
      type = types.nullOr (types.attrsOf types.anything);
    };

    preview_config = mkOption {
      default = null;
      type = types.nullOr (types.attrsOf types.anything);
    };
  };
in
{
  options.gitsigns = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    config = mkOption {
      default = { };
      type = configType;
    };
  };

  config.plugins.gitsigns = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "gitsigns.nvim";
    nvimRequireCheck = "gitsigns";
    runtimeDeps = [ pkgs.git ];
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim/";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.gitsigns ];

    luaInit = /* lua */ ''
      require('gitsigns').setup(${lua.toLua cfg.config})
    '';
  };
}
