{ pkgs, lib, ... }:

with lib;
let
  ripgrep = getExe pkgs.ripgrep;
in {
  config.nvim = {
    # TODO: split this up, create options, compose
    luaInit = /*lua*/''
      vim.loader.enable()

      -- terminal options
      vim.api.nvim_exec([[
        set t_Co=256
        set t_ZH=^\[\[3m
        set t_ZR=^\[\[23m
        let &t_Cs = "\e\[4:3m"
        let &t_Ce = "\e\[4:0m"
        let &t_ut=""
      ]], false)

      -- default save options
      vim.o.hidden = true
      vim.o.encoding = 'utf8'

      -- scroll and mouse options
      vim.o.mouse = 'a'
      vim.o.scrolloff = 2

      -- indentation options
      vim.o.autoindent = true
      vim.o.smartindent = false
      vim.o.breakindent = true

      -- default tab options
      vim.o.expandtab = true
      vim.o.tabstop = 2
      vim.o.softtabstop = 2
      vim.o.shiftwidth = 2

      -- tweak redraw timings
      vim.o.lazyredraw = true
      vim.o.updatetime = 500
      vim.o.timeoutlen = 500

      -- fold options
      vim.o.foldenable = true
      vim.o.foldmethod = 'indent'
      vim.o.foldnestmax = 9
      vim.o.foldlevelstart = 3

      -- search options
      vim.o.ignorecase = true
      vim.o.smartcase = true
      vim.o.infercase = true
      vim.o.hlsearch = false
      vim.o.incsearch = true
      vim.o.inccommand = 'nosplit'

      -- status options
      vim.o.laststatus = 2
      vim.o.statusline = '%F%m%r%h%w [%l,%c] [%L,%p%%]'

      -- disable backups and swaps
      vim.o.backup = false
      vim.o.writebackup = false
      vim.o.swapfile = false

      -- disable matchparen
      vim.o.showmatch = false
      vim.g.loaded_matchparen = 1

      -- no completion or startup messages
      vim.o.shortmess = vim.o.shortmess .. 'WcCIAa'

      -- line numbers
      vim.wo.number = true

      -- fill chars
      vim.opt.fillchars = {
        vert = '│',
        diff = '╱',
        horiz = '─',
        horizup = '┴',
        horizdown = '┬',
        vertleft = '┤',
        vertright = '├',
        verthoriz = '┼',
        eob = ' ',
      }

      -- list chars
      vim.o.list = true
      vim.opt.listchars = {
        nbsp = '␣',
        extends = '»',
        precedes = '«',
        tab = ' ',
      }

      -- splitting options
      vim.go.diffopt = 'filler,vertical,foldcolumn:0,closeoff,indent-heuristic,iwhite,algorithm:patience'
      vim.go.splitbelow = true
      vim.go.splitright = true
      vim.o.splitkeep = 'screen'
      vim.o.switchbuf = 'uselast'
      vim.o.previewheight = 5

      -- undo history
      local undodir = vim.fn.stdpath('cache') .. '/undo'
      if vim.fn.isdirectory(undodir) == 0 then
        vim.fn.mkdir(undodir, 'p')
      end

      vim.o.undodir = undodir
      vim.o.undofile = true
      vim.o.undolevels = 1000
      vim.o.undoreload = 10000

      -- display options
      vim.o.wrap = false
      vim.o.showmode = false
      vim.o.ruler = false
      vim.o.termguicolors = true
      vim.o.cmdheight = 0
      vim.wo.signcolumn = 'number'
      vim.wo.cursorline = true

      -- misc. options
      vim.o.completeopt = 'menuone,noinsert,noselect,popup'
      vim.o.pumheight = 10
      vim.o.winblend  = 5
      vim.o.backspace = 'indent,eol,start'
      vim.o.virtualedit = 'block' -- Allow going past the end of line in visual block mode
      vim.o.formatoptions = 'qjl1' -- Don't autoformat comments
      vim.o.synmaxcol = 300 -- Don't highlight long lines
      vim.o.path = '**' -- Use a recursive path (for :find)
      vim.o.gdefault = true -- Use //g for replacements by default

      -- wildmenu
      vim.opt.wildignore:append(
        '*.png,*.jpg,*.jpeg,*.gif,*.wav,*.aiff,*.dll,*.pdb,*.mdb,*.so,*.swp,*.zip,*.gz,*.bz2,*.meta,*.svg,*.cache,*/.git/*'
      )
      vim.o.wildmenu = true
      vim.o.wildmode = 'longest,list,full'

      -- built-in ftplugins should not change my keybindings
      vim.g.no_plugin_maps = true
      vim.cmd.filetype({ args = { 'plugin', 'on' } })
      vim.cmd.filetype({ args = { 'plugin', 'indent', 'on' } })

      --- ripgrep
      vim.o.grepprg = '${ripgrep} --vimgrep --no-heading --smart-case'
      vim.o.grepformat = '%f:%l:%c:%m,%f:%l:%m'

      -- define signs
      vim.fn.sign_define('DiagnosticSignError', { text = '●', texthl = 'DiagnosticSignError' })
      vim.fn.sign_define('DiagnosticSignWarn', { text = '◐', texthl = 'DiagnosticSignWarn' })
      vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })
      vim.fn.sign_define('DiagnosticSignInfo', { text = '○', texthl = 'DiagnosticSignInfo' })

      -- configure vim diagnostics
      vim.diagnostic.config({
        underline = true,
        signs = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_text = {
          severity = { min = vim.diagnostic.severity.W },
          source = 'if_many',
        },
        float = {
          show_header = true,
          source = 'if_many',
          border = 'rounded',
          focusable = false,
          severity_sort = true,
        },
      })

      -- customise hover window size
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        max_width = math.max(math.floor(vim.o.columns * 0.7), 100),
        max_height = math.max(math.floor(vim.o.lines * 0.3), 30),
      })

      -- hide sticky commands
      vim.api.nvim_create_autocmd({ 'CursorHold' }, {
        pattern = "*",
        callback = function()
          vim.defer_fn(function()
            if vim.api.nvim_get_mode().mode == 'n' then
              vim.cmd('echon ""')
            end
          end, 3000)
        end,
      })

      -- customise fold text
      function _G.custom_fold_text()
        local line_count = tostring(vim.v.foldend - vim.v.foldstart + 1)
        local first_line = vim.trim(vim.fn.getline(vim.v.foldstart))
        local last_line = vim.trim(vim.fn.getline(vim.v.foldstart))
        return "  " .. first_line .. " … " .. last_line .. " (" .. line_count .. " lines) "
      end
      vim.opt.foldtext = 'v:lua.custom_fold_text()'
    '';
  };
