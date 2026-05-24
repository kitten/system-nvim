{
  config.focus = {
    enable = true;

    config = {
      enable = true;
      autoresize = {
        enable = true;
        width = 0;
        height = 0;
        minwidth = 20;
        minheight = 5;
        height_quickfix = 10;
      };
      split = {
        bufnew = false;
        tmux = false;
      };
      ui = {
        number = false;
        relativenumber = false;
        cursorline = false;
        cursorcolumn = false;
        signcolumn = false;
        colorcolumn.enable = false;
        winhighlight = false;
      };
    };

    ignoreFiletypes = [
      "qf"
      "gitsigns-blame"
      "oil"
      "glance_preview"
      "glance_list"
      "fff_picker"
      "namu_picker"
    ];
  };
}
