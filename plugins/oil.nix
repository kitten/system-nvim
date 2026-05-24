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
  flake = inputs.nvim-oil;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.oil;
in
{
  options.oil = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config.plugins.oil = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "nvim-oil";
    nvimRequireCheck = [ "oil" ];
    meta.homepage = "https://github.com/barrettruth/canola.nvim/";
  };

  # oil replaces netrw
  config.vim.g = mkIf cfg.enable {
    loaded_netrw = 1;
    loaded_netrwPlugin = 1;
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.oil ];

    luaInit = /* lua */ ''
      require('oil').setup({
        default_file_explorer = true,
        delete_to_trash = false,
        skip_confirm_for_simple_edits = true,
        prompt_save_on_select_new_entry = true,
        cleanup_delay_ms = 2000,
        lsp_file_methods = {
          timeout_ms = 1000,
          autosave_changes = false,
        },
        constrain_cursor = 'editable',
        watch_for_changes = false,
        use_default_keymaps = true,
        keymaps = {
          ["<C-c>"] = false,
        },
        view_options = {
          show_hidden = false,
          is_hidden_file = function(name, bufnr)
            return vim.startswith(name, '.')
          end,
          is_always_hidden = function(name, bufnr)
            return name == '.DS_Store'
          end,
          natural_order = true,
          case_insensitive = true,
          sort = {
            { 'type', 'asc' },
            { 'name', 'asc' },
          },
        },
        float = {
          preview_split = 'auto',
          border = 'none',
          win_options = {
            winblend = 5,
          },
        },
        preview = {
          border = 'none',
          win_options = { winblend = 5 },
          update_on_cursor_moved = true,
        },
        progress = {
          border = 'none',
          minimized_border = 'none',
          win_options = { winblend = 5 },
        },
        ssh = { border = 'none', },
        keymaps_help = { border = 'none' },
      })
    '';
  };
}
