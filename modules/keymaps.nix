{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.keys;
in
{
  options.keys = {
    bindings = mkOption {
      default = [ ];
      type = types.listOf types.keymap;
      description = "Global keymaps, registered at startup.";
    };

    lsp = mkOption {
      default = [ ];
      type = types.listOf types.keymap;
      description = ''
        Buffer-local keymaps registered inside LspAttach. `options.buffer`
        is overridden with the attaching buffer ID at runtime.
      '';
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

  config = {
    nvim.luaInit = /* lua */ ''
      vim.g.mapleader = ${lua.toLua cfg.leader}
      vim.g.maplocalleader = ${lua.toLua cfg.localleader}

      ${nvim.mkKeymapLua cfg.bindings}

      ${optionalString cfg.disablePluginMaps /* lua */ ''
        vim.g.no_plugin_maps = true
      ''}
    '';

    # owned here, not in lsp.nix, so all keymap registration lives in one module
    autocmds = optionals (cfg.lsp != [ ]) [
      {
        event = "LspAttach";
        callback = lua.mkInline /* lua */ ''
          function(args)
            ${nvim.mkBufferedKeymapLua cfg.lsp "args.buf"}
          end
        '';
        desc = "Register keys.lsp on the attaching buffer";
      }
      {
        event = "LspDetach";
        callback = lua.mkInline /* lua */ ''
          function(args)
            -- LspDetach fires before the client is removed; defer the
            -- get_clients check so it reflects the post-detach state.
            vim.schedule(function()
              if next(vim.lsp.get_clients({ bufnr = args.buf })) ~= nil then return end
              ${nvim.mkBufferedKeymapDelLua cfg.lsp "args.buf"}
            end)
          end
        '';
        desc = "Unset keys.lsp once the last client leaves the buffer";
      }
    ];
  };
}
