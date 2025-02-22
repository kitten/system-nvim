{ lib, config, ... }:

with lib;
{
  imports = [
    ./keymaps.nix
    ./filetype.nix
    ./theme.nix
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
