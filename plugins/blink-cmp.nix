{ pkgs, lib, config, plugins, inputs, ... }:

with lib;
let
  flake = inputs.nvim-blink-cmp;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.blink-cmp;

  libExt = if pkgs.stdenv.hostPlatform.isDarwin then "dylib" else "so";

  blink-fuzzy-lib = pkgs.rustPlatform.buildRustPackage {
    inherit version src;
    pname = "blink-fuzzy-lib";
    env = {
      # TODO: remove this if plugin stops using nightly rust
      RUSTC_BOOTSTRAP = true;
    };
    nativeBuildInputs = [ git ];
    cargoLock = {
      allowBuiltinFetchGit = true;
      lockFile = writeTextFile {
        name = "Cargo.lock";
        text = builtins.readFile "${flake.outPath}/Cargo.lock";
      };
    };
  };
in {
  options.blink-cmp = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config.plugins.blink-cmp = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "nvim-blink-cmp";
    preInstall = ''
      mkdir -p target/release
      ln -s ${blink-fuzzy-lib}/lib/libblink_cmp_fuzzy.${libExt} target/release/libblink_cmp_fuzzy.${libExt}
    '';
    doInstallCheck = true;
    nvimRequireCheck = "blink-cmp";
    meta.homepage = "https://github.com/saghen/blink.cmp/";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.blink-cmp ];
  };
}
