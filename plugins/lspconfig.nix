{ pkgs, lib, config, plugins, inputs, ... }:

with lib;
let
  flake = inputs.nvim-lspconfig;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.lspconfig;
in {
  options.lspconfig = let
    serverConfigType = submoduleOpts {
      cmd = mkOption {
        description = "Arguments used to spawn the language server (must include executable)";
        type = types.listOf types.str;
      };
      filetypes = mkOption {
        description = "List of filetypes spawning this language server";
        default = null;
        type = types.nullOr (types.listOf types.str);
      };
      root_dir = mkOption {
        description = "Lua function to determine workspace root. One language server per workspace will be spawned.";
        default = null;
        type = types.nullOr types.rawLua;
      };
      init_options = mkOption {
        description = "sent as `initializeParams` during startup.";
        default = null;
        type = types.nullOr (types.attrsOf types.anything);
      };
      settings = mkOption {
        description = "sent during `workspace/didChangeConfiguration` shortly after startup";
        default = null;
        type = types.nullOr (types.attrsOf types.anything);
      };
    };
  in {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    capabilities = mkOption {
      description = "LSP capabilities to merge into default ones";
      default = { };
      type = types.attrsOf types.anything;
    };

    on_attach = mkOption {
      description = "Callback to call when new server is attached";
      default = null;
      type = types.nullOr types.rawLua;
    };

    configs = mkOption {
      default = { };
      type = types.attrsOf serverConfigType;
    };
  };

  config.plugins.lspconfig = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "nvim-lspconfig";
    nvimRequireCheck = [ "lspconfig" "lspconfig.util" ];
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.lspconfig ];
  };
}
