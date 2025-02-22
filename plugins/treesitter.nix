{ pkgs, lib, config, plugins, inputs, ... }:

with lib;
let
  flake = inputs.nvim-treesitter;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.treesitter;

  base = pkgs.vimPlugins.nvim-treesitter.withPlugins(grammars: with grammars; [
    astro 
    bash 
    c 
    comment 
    css
    git_rebase 
    gitattributes 
    gitcommit 
    gitignore
    go
    graphql 
    html 
    javascript
    jsdoc 
    json 
    json5 
    lua 
    make 
    markdown 
    markdown_inline 
    nix 
    prisma
    regex 
    rust 
    sql 
    svelte 
    terraform 
    tsx 
    typescript 
    vim 
    vue 
    yaml 
    yuck 
    zig 
  ]);
in {
  options.treesitter = let
    configType = types.submoduleOpts {
      auto_install = mkOption {
        default = false;
        type = types.bool;
      };

      highlight = types.submoduleOpts {
        enable = mkOption {
          default = true;
          type = types.bool;
        };
      };

      incremental_selection = types.submoduleOpts {
        enable = mkOption {
          default = false;
          type = types.bool;
        };

        keymaps = mkOption {
          default = null;
          type = types.nullOr (types.attrsOf types.str);
        };
      };

      extra = mkOption {
        default = { };
        type = types.attrsOf types.anything;
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

  config.plugins.treesitter = base.overrideAttrs (_: {
    inherit src version;
  });

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.treesitter ];

    initLua = let
      init = recursiveUpdate cfg.config.extra (removeAttrs cfg.config [ "extra" ]);
    in /*lua*/''
      require('nvim-treesitter.configs').setup(${lua.toLua init})
    '';
  };
}
