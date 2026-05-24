{ lib, ... }:

with lib;
{
  config.blink-cmp = {
    enable = true;

    config = {
      appearance = {
        nerd_font_variant = "mono";
        kind_icons = {
          Text = "";
          Method = "";
          Function = "";
          Constructor = "";
          Field = "";
          Variable = "";
          Class = "";
          Interface = "";
          Module = "";
          Property = "";
          Unit = "";
          Value = "";
          Enum = "";
          Keyword = "";
          Snippet = "";
          Color = "";
          File = "";
          Reference = "";
          Folder = "";
          EnumMember = "";
          Constant = "";
          Struct = "";
          Event = "";
          Operator = "";
          TypeParameter = "";
        };
      };

      keymap = {
        preset = "default";
        "<Tab>" = [
          "snippet_forward"
          "select_next"
          "fallback"
        ];
        "<S-Tab>" = [
          "snippet_backward"
          "select_prev"
          "fallback"
        ];
        "<CR>" = [
          "accept"
          "fallback"
        ];
        # close the menu but always fall through so <C-c> reaches vim's
        # mapping (which turns <C-c> → <Esc>, exiting insert mode)
        "<C-c>" = [
          (lua.mkInline /* lua */ "function(cmp) cmp.hide() end")
          "fallback"
        ];
      };

      sources = {
        min_keyword_length = 2;
        default = lua.mkInline /* lua */ ''
          function()
            for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
              if c.server_capabilities and c.server_capabilities.completionProvider then
                return { 'lsp', 'snippets' }
              end
            end
            return { 'lsp', 'snippets', 'buffer' }
          end
        '';
      };

      signature = {
        enabled = false;
      };

      completion = {
        list.selection.preselect = false;
        accept.auto_brackets.enabled = false;
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 200;
        };
      };

      # Runs on every keystroke — keep cheap. get_node():type() is the leaf
      # from the incremental parse tree (one FFI call); much cheaper than
      # get_captures_at_cursor() which executes every highlight query.
      enabled = lua.mkInline /* lua */ ''
        function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.b[buf].big then return false end
          if vim.bo[buf].filetype == 'gitcommit' then return false end
          local ok, node = pcall(vim.treesitter.get_node)
          if ok and node then
            local t = node:type()
            if t == 'comment' or t == 'line_comment' or t == 'block_comment' then
              return false
            end
          end
          return true
        end
      '';
    };
  };
}
