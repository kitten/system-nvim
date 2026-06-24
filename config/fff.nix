{ lib, ... }:

with lib;
let
  silent = {
    silent = true;
    noremap = true;
  };
in
{
  config = {
    fff = {
      enable = true;
      config = {
        layout = {
          height = 0.75;
          width = 0.85;
          prompt_position = "bottom";
          preview_position = "right";
          preview_size = 0.55;
        };
        frecency.enabled = false;
        keymaps = {
          close = [
            "<Esc>"
            "<C-c>"
          ];
        };
        hl.matched = "Search";
      };
    };

    keys.bindings =
      let
        atRoot =
          fn:
          lua.mkInline "function() require('fff').${fn}({ cwd = vim.fs.root(0, '.git') or vim.fn.getcwd() }) end";
      in
      [
        {
          mode = "n";
          key = "<leader>o";
          action = atRoot "find_files";
          options = silent // {
            desc = "Workspace Files";
          };
        }
        {
          mode = "n";
          key = "<leader>f";
          action = atRoot "live_grep";
          options = silent // {
            desc = "Live Grep";
          };
        }
      ];
  };
}
