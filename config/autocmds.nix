{ lib, ... }:

with lib;
{
  config = {
    # foldtext must be a global because vim.opt.foldtext takes a vim expression string
    nvim.luaInit = /* lua */ ''
      function _G.custom_fold_text()
        local line_count = tostring(vim.v.foldend - vim.v.foldstart + 1)
        local first_line = vim.trim(vim.fn.getline(vim.v.foldstart))
        local last_line  = vim.trim(vim.fn.getline(vim.v.foldend))
        return '  ' .. first_line .. ' … ' .. last_line .. ' (' .. line_count .. ' lines) '
      end
      vim.opt.foldtext = 'v:lua.custom_fold_text()'
    '';

    autocmds = [
      {
        event = "FileType";
        pattern = "markdown";
        desc = "Markdown wrap & linebreak";
        callback = lua.mkInline /* lua */ ''
          function()
            vim.opt_local.wrap = true
            vim.o.whichwrap = 'h,l'
            vim.opt_local.linebreak = true
            vim.opt_local.formatoptions = vim.opt_local.formatoptions + 'tcn12'
          end
        '';
      }

      {
        event = "BufReadPre";
        pattern = "*";
        desc = "Big-buffer detection";
        callback = lua.mkInline /* lua */ ''
          function()
            local buf = vim.api.nvim_get_current_buf()
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            vim.b[buf].big = ok and stats and (stats.size > 100 * 1024)
            if vim.b[buf].big then
              vim.opt_local.spell = false
              vim.opt_local.showmatch = false
              vim.opt_local.undofile = false
              vim.opt_local.foldmethod = 'manual'
            end
          end
        '';
      }

      {
        event = "CursorHold";
        pattern = "*";
        desc = "Hide sticky command message";
        callback = lua.mkInline /* lua */ ''
          function()
            vim.defer_fn(function()
              if vim.api.nvim_get_mode().mode == 'n' then
                vim.cmd('echon ""')
              end
            end, 3000)
          end
        '';
      }

      {
        event = "FileType";
        pattern = "*";
        desc = "Start treesitter highlight & indent";
        callback = lua.mkInline /* lua */ ''
          function(args)
            if vim.b[args.buf].big then return end
            pcall(vim.treesitter.start, args.buf)
            local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
            if lang then
              local ok, q = pcall(vim.treesitter.query.get, lang, 'indents')
              if ok and q then
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
              end
            end
          end
        '';
      }
    ];
  };
}
