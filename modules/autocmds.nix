{ lib, config, ... }:

with lib;
let
  cfg = config;
in
{
  options.autocmds = mkOption {
    default = [ ];
    type = types.listOf types.autocmd;
    description = "Autocommands registered at startup via vim.api.nvim_create_autocmd.";
  };

  config.nvim.luaInit = nvim.mkAutocmdLua cfg.autocmds;
}
