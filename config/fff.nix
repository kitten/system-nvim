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
        keymaps = {
          close = [
            "<Esc>"
            "<C-c>"
          ];
        };
        hl.matched = "Search";
      };
    };

    keys.bindings = [
      {
        mode = "n";
        key = "<leader>o";
        action = nvim.lazy "fff" "require('fff').find_files()";
        options = silent // {
          desc = "Workspace Files";
        };
      }
      {
        mode = "n";
        key = "<leader>f";
        action = nvim.lazy "fff" "require('fff').live_grep()";
        options = silent // {
          desc = "Live Grep";
        };
      }
    ];
  };
}
