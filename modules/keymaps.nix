{ pkgs, config, lib, ... }:

with lib;
let
  cfg = config.keys;
in {
  options.keys = {
    bindings = mkOption {
      default = [];
      type = types.listOf types.keymap;
    };

    leader = mkOption {
      default = " ";
      type = types.str;
    };

    localleader = mkOption {
      default = cfg.leader;
      type = types.str;
    };

    disablePluginMaps = mkEnableOption "whether built-in ftplugins can change keybindings";
  };

  config.nvim = {
    luaInit = /*lua*/''
      vim.g.mapleader = ${lua.toLua cfg.leader}
      vim.g.maplocalleader = ${lua.toLua cfg.localleader}

      ${nvim.mkKeymapLua cfg.bindings}

      ${optionalString cfg.disablePluginMaps /*lua*/''
        vim.g.no_plugin_maps = true
      ''}
    '';
  };
}
