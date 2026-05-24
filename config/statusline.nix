{
  config.statusline = {
    enable = true;

    sections = [
      {
        class = "mode";
        item = "mode";
      }
      {
        class = "high";
        item = "filename";
      }
      {
        class = "med";
        item = "git_status";
        hide = 100;
      }
      "%<"
      "%="
      {
        class = "error";
        item = "diag_error";
      }
      {
        class = "warning";
        item = "diag_warn";
      }
      {
        class = "high";
        item = "filetype";
        hide = 80;
      }
      {
        class = "mode";
        item = "progress";
      }
    ];
  };
}
