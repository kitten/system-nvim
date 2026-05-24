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
  flake = inputs.nvim-namu;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.namu;

  moduleType =
    name: defaultEnable:
    types.submoduleOpts {
      enable = mkOption {
        default = defaultEnable;
        type = types.bool;
      };
      options = mkOption {
        default = { };
        type = types.attrsOf types.anything;
      };
    };
in
{
  options.namu = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    config = mkOption {
      default = { };
      type = types.submoduleOpts {
        global = mkOption {
          default = { };
          type = types.attrsOf types.anything;
        };
        namu_symbols = mkOption {
          default = { };
          type = moduleType "namu_symbols" true;
        };
        selecta = mkOption {
          default = { };
          type = moduleType "selecta" true;
        };
        callhierarchy = mkOption {
          default = { };
          type = moduleType "callhierarchy" true;
        };
        workspace = mkOption {
          default = { };
          type = moduleType "workspace" true;
        };
        diagnostics = mkOption {
          default = { };
          type = moduleType "diagnostics" true;
        };
        watchtower = mkOption {
          default = { };
          type = moduleType "watchtower" false;
        };
        namu_ctags = mkOption {
          default = { };
          type = moduleType "namu_ctags" false;
        };
        ui_select = mkOption {
          default = { };
          type = moduleType "ui_select" false;
        };
        colorscheme = mkOption {
          default = { };
          type = moduleType "colorscheme" false;
        };
      };
    };
  };

  config.plugins.namu = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "namu.nvim";
    nvimRequireCheck = [ "namu" ];
    meta.homepage = "https://github.com/bassamsdata/namu.nvim";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.namu ];

    luaInit = nvim.lazyInit "namu" /* lua */ ''
      require('namu').setup(${lua.toLua cfg.config})
    '';
  };
}
