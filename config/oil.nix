{ lib, ... }:

with lib;
let
  silent = {
    silent = true;
    noremap = true;
  };
in
{
  config = {
    oil.enable = true;

    keys.bindings = [
      {
        mode = "n";
        key = "-";
        action = lua.mkInline "function() require('oil').open() end";
        options = silent // {
          desc = "Open Oil";
        };
      }
    ];
  };
}
