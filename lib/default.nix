{ lib }:

let
  libOverlay = self: prev: let
    libArgs = { lib = self; };
  in {
    colors = import ./colors.nix libArgs;
    lua = import ./lua.nix libArgs;
    types = prev.types // (import ./types.nix libArgs);
    nvim = import ./nvim.nix libArgs;
  };
in lib.fix (lib.extends libOverlay (f: lib))
