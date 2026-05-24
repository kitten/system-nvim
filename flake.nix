{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    language-servers = {
      url = "github:kitten/language-servers.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    nvim-blink-cmp = {
      url = "github:Saghen/blink.cmp/v1";
      flake = false;
    };

    nvim-gitsigns = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    nvim-oil = {
      url = "github:stevearc/oil.nvim";
      flake = false;
    };

    nvim-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects/main";
      flake = false;
    };

    nvim-fff = {
      url = "github:dmtrKovalenko/fff.nvim";
      flake = false;
    };

    nvim-namu = {
      url = "github:bassamsdata/namu.nvim";
      flake = false;
    };

    nvim-glance = {
      url = "github:DNLHC/glance.nvim";
      flake = false;
    };

    nvim-focus = {
      url = "github:nvim-focus/focus.nvim";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      language-servers,
      ...
    }@inputs:
    let
      inherit (flake-utils.lib) eachDefaultSystem;
    in
    eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ language-servers.overlays.default ];
        };
        args = { inherit pkgs inputs; };
        makeNeovim = import ./nvim-module.nix args;
        modules = config: [
          ./plugins/default.nix
          ./config/default.nix
          { inherit config; }
        ];
      in
      {
        packages.neovim = (makeNeovim (modules { })).package;
        formatter = pkgs.writeShellApplication {
          name = "nixfmt-flake";
          runtimeInputs = [
            pkgs.nixfmt-rfc-style
            pkgs.findutils
          ];
          text = ''
            if [ $# -gt 0 ]; then
              exec nixfmt "$@"
            else
              find . -type f -name '*.nix' -not -path '*/\.*' -print0 | xargs -0r nixfmt
            fi
          '';
        };
      }
    );
}
