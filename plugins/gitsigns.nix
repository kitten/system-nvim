{ pkgs, lib, config, plugins, inputs, ... }:

with lib;
let
  flake = inputs.nvim-gitsigns;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.gitsigns;
in {
  options.gitsigns = let
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

      preview_config = mkOption {
        default = null;
        description = "Options passed to nvim_open_win";
        type = types.nullOr (types.attrsOf types.anything);
      };

      on_attach = mkOption {
        default = lua.mkInline ''
          function (buf)
            ${nvim.mkKeymapLua cfg.keymaps}
          end
        '';
        type = types.rawLua;
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

    keymaps = let
      mkGitsignsActionsKeymap = { action, options } @ opts: opts // {
        options = options // { buffer = true; };
        action = let
          code = ''
            function()
              pcall(require('gitsigns.actions').${action}, nil)
            end
          '';
        in if !(types.rawLua.check action) then lua.mkInline code else action;
      };
    in mkOption {
      default = [ ];
      type = types.listOf types.keymap;
      apply = v: map mkGitsignsActionsKeymap v;
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

    luaInit = /*lua*/''
      require('gitsigns').setup(${lua.toLua cfg.config})
    '';
  };
}
