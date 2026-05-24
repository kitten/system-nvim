{ pkgs, lib, ... }:

with lib;
{
  config = {
    vim = {
      g = {
        loaded_matchparen = 1;
      };

      o = {
        hidden = true;
        encoding = "utf8";

        mouse = "a";
        scrolloff = 2;

        autoindent = true;
        smartindent = false;
        breakindent = true;

        expandtab = true;
        tabstop = 2;
        softtabstop = 2;
        shiftwidth = 2;

        lazyredraw = true;
        updatetime = 500;
        timeoutlen = 500;

        # foldexpr / foldmethod get overridden per-FT by autocmds
        foldenable = true;
        foldmethod = "indent";
        foldnestmax = 9;
        foldlevelstart = 3;

        ignorecase = true;
        smartcase = true;
        infercase = true;
        hlsearch = false;
        incsearch = true;
        inccommand = "nosplit";

        backup = false;
        writebackup = false;
        swapfile = false;

        showmatch = false;

        # undodir set in nvim.luaInit because it needs runtime mkdir
        undofile = true;
        undolevels = 1000;
        undoreload = 10000;

        wrap = false;
        showmode = false;
        ruler = false;
        termguicolors = true;
        cmdheight = 0;
        list = true;

        completeopt = "menuone,noinsert,noselect,popup";
        pumheight = 10;
        winblend = 5;
        backspace = "indent,eol,start";
        virtualedit = "block";
        formatoptions = "qjl1";
        synmaxcol = 300;
        path = "**";
        gdefault = true;

        wildmenu = true;
        wildmode = "longest,list,full";

        grepprg = "${getExe pkgs.ripgrep} --vimgrep --no-heading --smart-case";
        grepformat = "%f:%l:%c:%m,%f:%l:%m";
      };

      opt = {
        fillchars = {
          vert = "│";
          diff = "╱";
          horiz = "─";
          horizup = "┴";
          horizdown = "┬";
          vertleft = "┤";
          vertright = "├";
          verthoriz = "┼";
          eob = " ";
        };
        listchars = {
          nbsp = "␣";
          extends = "»";
          precedes = "«";
          tab = "  ";
        };
      };

      wo = {
        number = true;
        signcolumn = "number";
        cursorline = true;
      };

      go = {
        diffopt = "filler,vertical,foldcolumn:0,closeoff,indent-heuristic,iwhite,algorithm:patience";
        splitbelow = true;
        splitright = true;
        splitkeep = "screen";
        switchbuf = "uselast";
        previewheight = 5;
      };
    };

    nvim.luaInit = /* lua */ ''
      vim.loader.enable()

      vim.api.nvim_exec([[
        set t_Co=256
        set t_ZH=^\[\[3m
        set t_ZR=^\[\[23m
        let &t_Cs = "\e\[4:3m"
        let &t_Ce = "\e\[4:0m"
        let &t_ut=""
      ]], false)

      -- append, don't overwrite
      vim.o.shortmess = vim.o.shortmess .. 'WcCIAa'

      vim.opt.wildignore:append(
        '*.png,*.jpg,*.jpeg,*.gif,*.wav,*.aiff,*.dll,*.pdb,*.mdb,*.so,*.swp,*.zip,*.gz,*.bz2,*.meta,*.svg,*.cache,*/.git/*'
      )

      do
        local undodir = vim.fn.stdpath('cache') .. '/undo'
        if vim.fn.isdirectory(undodir) == 0 then
          vim.fn.mkdir(undodir, 'p')
        end
        vim.o.undodir = undodir
      end
    '';
  };
}
