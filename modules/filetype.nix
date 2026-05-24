{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.filetype;
in
{
  options.filetype = {
    enable = mkOption {
      default = true;
      type = types.bool;
    };

    plugin = mkOption {
      default = true;
      type = types.bool;
      apply = v: if v then "on" else "off";
    };

    indent = mkOption {
      default = false;
      type = types.bool;
      apply = v: if v then "on" else "off";
    };

    extension = mkOption {
      default = { };
      type = types.attrsOf types.str;
    };

    pattern = mkOption {
      default = { };
      type = types.attrsOf types.str;
    };
  };

  config.nvim = {
    luaInit =
      if cfg.enable then
        /* lua */ ''
          vim.cmd.filetype({ args = { 'plugin', ${lua.toLua cfg.plugin} } })
          vim.cmd.filetype({ args = { 'plugin', 'indent', ${lua.toLua cfg.indent} } })

          vim.filetype.add({
            extension = ${lua.toLua cfg.extension},
            pattern = ${lua.toLua cfg.pattern},
          })
        ''
      else
        /* lua */ "vim.cmd.filetype({ args = { 'off' } })";
  };
}
