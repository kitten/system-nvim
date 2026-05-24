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
  flake = inputs.nvim-focus;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.focus;

  autoresizeType = types.submoduleOpts {
    enable = mkOption {
      default = true;
      type = types.bool;
    };
    # 0 → let focus.nvim compute the golden ratio
    width = mkOption {
      default = 0;
      type = types.int;
    };
    height = mkOption {
      default = 0;
      type = types.int;
    };
    minwidth = mkOption {
      default = 20;
      type = types.int;
    };
    minheight = mkOption {
      default = 5;
      type = types.int;
    };
    height_quickfix = mkOption {
      default = 10;
      type = types.int;
    };
  };

  splitType = types.submoduleOpts {
    bufnew = mkOption {
      default = false;
      type = types.bool;
    };
    tmux = mkOption {
      default = false;
      type = types.bool;
    };
  };

  colorcolumnType = types.submoduleOpts {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
    list = mkOption {
      default = null;
      type = types.nullOr types.str;
    };
  };

  uiType = types.submoduleOpts {
    number = mkOption {
      default = false;
      type = types.bool;
    };
    relativenumber = mkOption {
      default = false;
      type = types.bool;
    };
    cursorline = mkOption {
      default = false;
      type = types.bool;
    };
    cursorcolumn = mkOption {
      default = false;
      type = types.bool;
    };
    signcolumn = mkOption {
      default = false;
      type = types.bool;
    };
    winhighlight = mkOption {
      default = false;
      type = types.bool;
    };
    colorcolumn = mkOption {
      default = { };
      type = colorcolumnType;
    };
  };
in
{
  options.focus = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    config = mkOption {
      default = { };
      type = types.submoduleOpts {
        enable = mkOption {
          default = true;
          type = types.bool;
        };
        autoresize = mkOption {
          default = { };
          type = autoresizeType;
        };
        split = mkOption {
          default = { };
          type = splitType;
        };
        ui = mkOption {
          default = { };
          type = uiType;
        };
      };
    };

    ignoreFiletypes = mkOption {
      default = [ ];
      type = types.listOf types.str;
      description = "Filetypes for which focus auto-resize is disabled.";
    };
  };

  config = {
    plugins.focus = pkgs.vimUtils.buildVimPlugin {
      inherit src version;
      pname = "focus.nvim";
      nvimRequireCheck = [ "focus" ];
      meta.homepage = "https://github.com/nvim-focus/focus.nvim";
    };

    nvim = mkIf cfg.enable {
      plugins = [ plugins.focus ];
      luaInit = /* lua */ ''
        require('focus').setup(${lua.toLua cfg.config})
      '';
    };

    autocmds = mkIf cfg.enable (
      optionals (cfg.ignoreFiletypes != [ ]) [
        {
          event = "FileType";
          pattern = cfg.ignoreFiletypes;
          desc = "Disable focus auto-resize for ignored filetypes";
          callback = lua.mkInline "function() vim.b.focus_disable = true end";
        }
      ]
    );
  };
}
