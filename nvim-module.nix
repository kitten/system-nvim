{ pkgs, inputs, ... }@args:

let
  makeEvaled =
    modules:
    pkgs.lib.evalModules {
      class = "nvim";
      specialArgs = {
        inherit pkgs inputs;
        lib = import ./lib { lib = pkgs.lib; };
        modulesPath = builtins.toString ./.;
      };
      modules = [ ./modules ] ++ modules;
    };
in
modules: (makeEvaled modules).config.output
