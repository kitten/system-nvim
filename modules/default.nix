{ lib, config, ... }:

with lib;
{
  imports = [
    ./keymaps.nix
    ./autocmds.nix
    ./options.nix
    ./filetype.nix
    ./theme.nix
    ./statusline.nix
    ./lsp.nix
    ./output.nix
  ];

  options = {
    plugins = mkOption {
      default = { };
      type = types.lazyAttrsOf types.package;
    };
  };

  config = {
    _module.args.plugins = config.plugins;
  };
}
