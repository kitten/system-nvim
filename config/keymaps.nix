{ lib, ... }:

with lib;
let
  silent = {
    silent = true;
    noremap = true;
  };
  expr = silent // {
    expr = true;
  };

  inline = code: lua.mkInline code;
in
{
  config.keys = {
    leader = " ";
    disablePluginMaps = true;

    bindings = [
      {
        mode = "";
        key = "<Space>";
        action = "<nop>";
        options = silent;
      }
      {
        mode = "";
        key = "<F1>";
        action = "<nop>";
        options = silent;
      }

      {
        mode = "";
        key = "<c-c>";
        action = "<esc>";
        options = silent;
      }
      {
        mode = "!";
        key = "<c-c>";
        action = "<esc>";
        options = silent;
      }

      {
        mode = "";
        key = "<c-w>,";
        action = ":vsp<cr>";
        options = silent;
      }
      {
        mode = "";
        key = "<c-w>.";
        action = ":sp<cr>";
        options = silent;
      }

      {
        mode = "n";
        key = ";";
        action = ":";
        options = silent;
      }

      # X / x → black-hole register
      {
        mode = "";
        key = "X";
        action = "\"_d";
        options = silent;
      }
      {
        mode = "n";
        key = "XX";
        action = "\"_dd";
        options = silent;
      }
      {
        mode = "v";
        key = "x";
        action = "\"_d";
        options = silent;
      }
      {
        mode = "n";
        key = "x";
        action = "v\"_d";
        options = silent;
      }

      {
        mode = "x";
        key = "Y";
        action = "\"+y";
        options = silent;
      }
      {
        mode = "x";
        key = "<m-c>";
        action = "\"+y";
        options = silent;
      }
      {
        mode = "x";
        key = "<m-v>";
        action = "\"+p";
        options = silent;
      }
      {
        mode = "n";
        key = "<m-v>";
        action = "\"+P";
        options = silent;
      }

      {
        mode = "v";
        key = "<";
        action = "<gv";
        options = silent;
      }
      {
        mode = "v";
        key = ">";
        action = ">gv";
        options = silent;
      }

      {
        mode = [
          "n"
          "x"
        ];
        key = "j";
        action = "v:count == 0 ? 'gj' : 'j'";
        options = expr;
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "k";
        action = "v:count == 0 ? 'gk' : 'k'";
        options = expr;
      }

      {
        mode = "x";
        key = ".";
        action = "<cmd>norm .<cr>";
        options = silent;
      }

      {
        mode = "v";
        key = "@";
        action = ":<C-u>execute \":'<,'>normal @\".nr2char(getchar())<CR>";
        options = silent;
      }

      {
        mode = "n";
        key = "<bar>";
        action = "<cmd>norm zc<cr>";
        options = silent;
      }
      {
        mode = "n";
        key = "<bslash>";
        action = "<cmd>norm za<cr>";
        options = silent;
      }

      {
        mode = "n";
        key = "<leader>h";
        action = "<cmd>bp<cr>";
        options = silent // {
          desc = "Previous Buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>l";
        action = "<cmd>bn<cr>";
        options = silent // {
          desc = "Next Buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>j";
        action = "<cmd>enew<cr>";
        options = silent // {
          desc = "New Buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>k";
        action = "<cmd>bp <bar> bd #<cr>";
        options = silent // {
          desc = "Close Buffer";
        };
      }

      {
        mode = "n";
        key = "<leader>b";
        action = ":ls<cr>:b ";
        options = {
          silent = false;
          noremap = true;
          desc = "Buffer";
        };
      }

      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>copen<cr>";
        options = silent // {
          desc = "Quickfix";
        };
      }
      {
        mode = "n";
        key = "<leader>p";
        action = "<cmd>lopen<cr>";
        options = silent // {
          desc = "Location list";
        };
      }

      {
        mode = "n";
        key = "<c-e>";
        action = inline /* lua */ ''
          function() print(vim.inspect(vim.treesitter.get_captures_at_cursor(0))) end
        '';
        options = silent // {
          desc = "Output Treesitter Token";
        };
      }
    ];
  };
}
