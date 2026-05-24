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
  flake = inputs.nvim-treesitter-textobjects;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.treesitter-textobjects;

  selectType = types.submoduleOpts {
    lookahead = mkOption {
      default = true;
      type = types.bool;
    };

    selection_modes = mkOption {
      default = {
        "@parameter.outer" = "v";
        "@function.outer" = "V";
        "@class.outer" = "<c-v>";
      };
      type = types.attrsOf types.str;
      description = "Capture group → selection mode.";
    };

    keymaps = mkOption {
      default = {
        af = "@function.outer";
        "if" = "@function.inner";
        ac = "@call.outer";
        ic = "@call.inner";
      };
      type = types.attrsOf types.str;
      description = "Key → capture group; synthesised into keys.bindings.";
    };
  };

  mkSelectBinding = key: capture: {
    mode = [
      "x"
      "o"
    ];
    inherit key;
    action = lua.mkInline /* lua */ ''
      function()
        require('nvim-treesitter-textobjects.select').select_textobject(${lua.toLua capture}, 'textobjects')
      end
    '';
    options = {
      silent = true;
      desc = "select ${capture}";
    };
  };
in
{
  options.treesitter-textobjects = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    select = mkOption {
      default = { };
      type = selectType;
    };
  };

  config = {
    plugins.treesitter-textobjects = pkgs.vimUtils.buildVimPlugin {
      inherit src version;
      pname = "nvim-treesitter-textobjects";
      dependencies = [ plugins.treesitter ];
      nvimRequireCheck = [ "nvim-treesitter-textobjects" ];
      meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
    };

    nvim = mkIf cfg.enable {
      plugins = [ plugins.treesitter-textobjects ];

      luaInit = /* lua */ ''
        require('nvim-treesitter-textobjects').setup(${
          lua.toLua {
            select = {
              inherit (cfg.select) lookahead selection_modes;
            };
          }
        })
      '';
    };

    keys.bindings = mkIf cfg.enable (mapAttrsToList mkSelectBinding cfg.select.keymaps);
  };
}
