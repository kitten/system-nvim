{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.lsp;

  serverType = types.submodule {
    options = {
      enable = mkOption {
        default = true;
        type = types.bool;
        description = "Whether to pass this server to vim.lsp.enable().";
      };

      cmd = mkOption {
        type = types.listOf types.str;
      };

      filetypes = mkOption {
        default = null;
        type = types.nullOr (types.listOf types.str);
      };

      root_markers = mkOption {
        default = null;
        type = types.nullOr (types.listOf types.str);
      };

      workspace_required = mkOption {
        default = null;
        type = types.nullOr types.bool;
        description = ''
          If true, the server only starts when a `root_dir` is found via
          `root_markers`. Without this, Neovim still launches the server in
          single-file mode when no marker matches.
        '';
      };

      init_options = mkOption {
        default = null;
        type = types.nullOr (types.attrsOf types.anything);
      };

      settings = mkOption {
        default = null;
        type = types.nullOr (types.attrsOf types.anything);
      };
    };
  };

  # drop null fields so unset options don't reach Lua as `nil`
  serverConfigTable =
    server:
    filterAttrs (k: v: v != null && k != "enable") {
      inherit (server)
        cmd
        filetypes
        root_markers
        workspace_required
        init_options
        settings
        ;
    };

  enabledServers = filterAttrs (_: s: s.enable) cfg.servers;
in
{
  options.lsp = {
    servers = mkOption {
      default = { };
      type = types.attrsOf serverType;
    };

    onAttach = mkOption {
      default = "";
      type = types.lines;
      description = ''
        Lua run inside the LspAttach callback. `buf` is in scope. For
        keymaps use `keys.lsp` instead.
      '';
    };
  };

  config.nvim = mkIf (cfg.servers != { }) {
    luaInit = /* lua */ ''
      ${concatStringsSep "\n" (
        mapAttrsToList (
          name: server: "vim.lsp.config(${lua.toLua name}, ${lua.toLua (serverConfigTable server)})"
        ) cfg.servers
      )}

      vim.lsp.enable(${lua.toLua (attrNames enabledServers)})

      -- silence vim.notify in insert mode (avoids hit-enter spam with cmdheight=0)
      do
        local original_notify = vim.notify
        vim.notify = function(msg, level, opts)
          if vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' then
            vim.api.nvim_echo({{ tostring(msg) }}, true, { verbose = true })
            return
          end
          return original_notify(msg, level, opts)
        end
      end

      ${optionalString (cfg.onAttach != "") /* lua */ ''
        vim.api.nvim_create_autocmd('LspAttach', {
          callback = function(args)
            local buf = args.buf
            ${cfg.onAttach}
          end,
          desc = 'lsp.onAttach',
        })
      ''}
    '';
  };
}
