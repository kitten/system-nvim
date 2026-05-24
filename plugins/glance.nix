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
  flake = inputs.nvim-glance;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.glance;

  borderType = types.submoduleOpts {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
    chars = mkOption {
      default = null;
      type = types.nullOr (types.attrsOf types.str);
    };
  };

  listType = types.submoduleOpts {
    position = mkOption {
      default = "right";
      type = types.enum [
        "left"
        "right"
      ];
    };
    width = mkOption {
      default = 0.33;
      type = types.either types.float types.int;
    };
  };

  themeType = types.submoduleOpts {
    enable = mkOption {
      default = true;
      type = types.bool;
    };
    mode = mkOption {
      default = "auto";
      type = types.enum [
        "auto"
        "darken"
        "brighten"
      ];
    };
  };
in
{
  options.glance = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    config = mkOption {
      default = { };
      type = types.submoduleOpts {
        height = mkOption {
          default = 18;
          type = types.int;
        };
        border = mkOption {
          default = { };
          type = borderType;
        };
        list = mkOption {
          default = { };
          type = listType;
        };
        theme = mkOption {
          default = { };
          type = themeType;
        };
        preview_win_opts = mkOption {
          default = { };
          type = types.attrsOf types.anything;
        };
        mappings = mkOption {
          default = { };
          type = types.attrsOf types.anything;
        };
      };
    };
  };

  config.plugins.glance = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "glance.nvim";
    nvimRequireCheck = [ "glance" ];
    meta.homepage = "https://github.com/DNLHC/glance.nvim";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.glance ];

    luaInit = /* lua */ ''
      require('glance').setup(${lua.toLua cfg.config})
    '';
  };
}
