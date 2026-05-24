{ lib, ... }:

with lib;
let
  silent = {
    silent = true;
    noremap = true;
  };

  # pcall: gitsigns.actions may not be loaded yet on first keypress
  mkAction =
    name:
    lua.mkInline /* lua */ ''
      function() pcall(require('gitsigns.actions').${name}, nil) end
    '';
in
{
  config = {
    gitsigns = {
      enable = true;

      config = {
        signcolumn = true;
        numhl = false;
        linehl = false;
        word_diff = false;
        current_line_blame = false;

        signs = {
          add = {
            text = "│";
          };
          change = {
            text = "│";
          };
          delete = {
            text = "";
          };
          topdelete = {
            text = "";
          };
          changedelete = {
            text = "";
          };
        };

        diff_opts = {
          algorithm = "histogram";
          internal = true;
          linematch = true;
          indent_heuristic = true;
          ignore_blank_lines = true;
          ignore_whitespace_change = true;
          ignore_whitespace_change_at_eol = true;
        };

        preview_config = {
          border = "none";
          style = "minimal";
          relative = "cursor";
          row = 1;
          col = 0;
        };
      };
    };

    keys.bindings = [
      {
        mode = "n";
        key = "]c";
        action = mkAction "next_hunk";
        options = silent // {
          desc = "Next Git Hunk";
        };
      }
      {
        mode = "n";
        key = "[c";
        action = mkAction "prev_hunk";
        options = silent // {
          desc = "Previous Git Hunk";
        };
      }
      {
        mode = "n";
        key = "gb";
        action = mkAction "blame_line";
        options = silent // {
          desc = "Blame Line";
        };
      }
      {
        mode = "n";
        key = "gB";
        action = mkAction "blame";
        options = silent // {
          desc = "Blame Buffer";
        };
      }
      {
        mode = "n";
        key = "gh";
        action = mkAction "preview_hunk_inline";
        options = silent // {
          desc = "Show Git Hunk";
        };
      }
      {
        mode = "n";
        key = "gs";
        action = mkAction "stage_hunk";
        options = silent // {
          desc = "Stage Git Hunk";
        };
      }
      {
        mode = "n";
        key = "gS";
        action = mkAction "undo_stage_hunk";
        options = silent // {
          desc = "Unstage Git Hunk";
        };
      }
      {
        mode = "n";
        key = "gt";
        action = mkAction "diffthis";
        options = silent // {
          desc = "Diff against HEAD";
        };
      }
      {
        mode = "n";
        key = "gT";
        action = lua.mkInline /* lua */ ''
          function() pcall(require('gitsigns.actions').diffthis, '~') end
        '';
        options = silent // {
          desc = "Diff against HEAD~1";
        };
      }
    ];
  };
}
