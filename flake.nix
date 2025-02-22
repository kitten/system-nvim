{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    
    nvim-blink-cmp = {
      url = "github:Saghen/blink.cmp";
      flake = false;
    };

    nvim-gitsigns = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    nvim-golden-size = {
      url = "github:dm1try/golden_size";
      flake = false;
    };

    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };

    nvim-lspkind = {
      url = "github:onsails/lspkind-nvim";
      flake = false;
    };

    nvim-oil = {
      url = "github:stevearc/oil.nvim";
      flake = false;
    };

    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };

    nvim-treesitter-refactor = {
      url = "github:nvim-treesitter/nvim-treesitter-refactor";
      flake = false;
    };

    nvim-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects";
      flake = false;
    };

    nvim-heirline = {
      url = "github:rebelot/heirline.nvim";
      flake = false;
    };
  };

  outputs = { nixpkgs, flake-utils, ... } @ inputs: let
    inherit (flake-utils.lib) eachDefaultSystem;
  in eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    args = { inherit pkgs inputs; };
    makeNeovim = import ./nvim-module.nix args;
    modules = config: [
      ./plugins/default.nix
      { inherit config; }
    ];
  in {
    packages.neovim = (makeNeovim (modules { })).package;
  });
}
