{ config, lib, pkgs, ... }:

with lib;
let
  pluginWithConfigType = types.submodule {
    options = {
      config = mkOption {
        type = types.lines;
        description = "vimscript for this plugin to be placed in init.vim";
        default = "";
      };

      optional = mkEnableOption "optional" // {
        description = "Don't load by default (load with :packadd)";
      };

      plugin = mkOption {
        type = types.package;
        description = "vim plugin";
      };
    };
  };

  nvimType = types.submodule {
    options = {
      autoconfigure = mkOption {
        description = "appends custom configuration from plugins to the wrapper automatically";
        default = true;
        type = types.bool;
      };

      autowrapRuntimeDeps = mkOption {
        description = "append to PATH runtime deps of plugins";
        default = true;
        type = types.bool;
      };

      withPython3 = mkOption {
        default = true;
        type = types.bool;
      };

      withNodeJs = mkOption {
        default = false;
        type = types.bool;
      };

      withPerl = mkOption {
        default = false;
        type = types.bool;
      };

      withRuby = mkOption {
        default = true;
        type = types.bool;
      };

      vimAlias = mkOption {
        description = "Whether to create symlink from vim to nvim";
        default = false;
        type = types.bool;
      };

      viAlias = mkOption {
        description = "Whether to create symlink from vi to nvim";
        default = false;
        type = types.bool;
      };

      vimlInit = mkOption {
        description = "vimL configuration contents to source in generated init.lua";
        default = "";
        type = types.lines;
      };

      luaInit = mkOption {
        description = "Lua configuration contents to source in generated init.lua";
        default = "";
        type = types.lines;
      };

      plugins = mkOption {
        description = "List of vim plugins to install";
        default = [ ];
        type = types.listOf (types.nullOr (types.either types.package pluginWithConfigType));
        apply = builtins.filter (p: p != null);
      };
    };
  };

  outputType = types.submodule {
    options = {
      package = mkOption {
        readOnly = true;
        type = types.package;
      };
    };
  };
in {
  options = {
    package = mkOption {
      default = pkgs.neovim-unwrapped;
      type = types.package;
    };

    nvim = mkOption {
      default = { };
      type = nvimType;
    };

    output = mkOption {
      readOnly = true;
      type = outputType;
    };
  };

  config = {
    output.package = pkgs.wrapNeovimUnstable config.package (config.nvim // {
      extraName = "-system";
      withPython2 = false;
      wrapRc = true;
      neovimRcContent = config.nvim.vimlInit;
      luaRcContent = config.nvim.luaInit;
    });
  };
}
