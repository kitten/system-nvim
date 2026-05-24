{
  pkgs,
  lib,
  config,
  plugins,
  inputs,
  ...
}:

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
      # TODO: drop if blink stops requiring nightly rust
      RUSTC_BOOTSTRAP = true;
      # Lua symbols are resolved at runtime by Neovim's embedded LuaJIT
      RUSTFLAGS = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";
    };
    nativeBuildInputs = [ pkgs.git ];
    cargoLock = {
      allowBuiltinFetchGit = true;
      lockFile = pkgs.writeTextFile {
        name = "Cargo.lock";
        text = builtins.readFile "${flake.outPath}/Cargo.lock";
      };
    };
  };

  appearanceType = types.submoduleOpts {
    nerd_font_variant = mkOption {
      default = "mono";
      type = types.enum [
        "mono"
        "normal"
      ];
    };

    kind_icons = mkOption {
      default = { };
      type = types.attrsOf types.str;
      description = "LSP CompletionItemKind → glyph.";
    };
  };

  keymapType = types.submodule {
    # Allow arbitrary key→action overrides alongside the typed `preset` enum.
    freeformType = types.attrsOf types.anything;
    options = {
      preset = mkOption {
        default = "default";
        type = types.enum [
          "default"
          "super-tab"
          "enter"
          "none"
        ];
      };
    };
  };

  sourcesType = types.submoduleOpts {
    default = mkOption {
      default = [
        "lsp"
        "snippets"
        "buffer"
      ];
      type = types.either (types.listOf types.str) types.rawLua;
    };
    min_keyword_length = mkOption {
      default = null;
      type = types.nullOr types.int;
    };
  };

  signatureType = types.submoduleOpts {
    enabled = mkOption {
      default = false;
      type = types.bool;
    };
  };

  fuzzyType = types.submoduleOpts {
    # Defaults reflect that the Nix derivation bundles libblink_cmp_fuzzy:
    # the rust matcher is always available, so don't warn or download.
    implementation = mkOption {
      default = "prefer_rust";
      type = types.enum [
        "prefer_rust_with_warning"
        "prefer_rust"
        "rust"
        "lua"
      ];
    };
    prebuilt_binaries = mkOption {
      default = { };
      type = types.submoduleOpts {
        download = mkOption {
          default = false;
          type = types.bool;
        };
      };
    };
  };
in
{
  options.blink-cmp = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    config = mkOption {
      default = { };
      type = types.submoduleOpts {
        appearance = mkOption {
          default = { };
          type = appearanceType;
        };
        keymap = mkOption {
          default = { };
          type = keymapType;
        };
        sources = mkOption {
          default = { };
          type = sourcesType;
        };
        signature = mkOption {
          default = { };
          type = signatureType;
        };
        fuzzy = mkOption {
          default = { };
          type = fuzzyType;
        };
        completion = mkOption {
          default = { };
          type = types.attrsOf types.anything;
        };
        enabled = mkOption {
          default = null;
          type = types.nullOr types.rawLua;
        };
      };
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
    nvimRequireCheck = "blink.cmp";
    meta.homepage = "https://github.com/saghen/blink.cmp/";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.blink-cmp ];

    # Pre-warm the rust submodule before setup. blink's async setup runs the
    # detection pcall inside a fast event, where Neovim's loader returns an
    # empty rtp cache and the require fails. Loading it here (synchronously,
    # outside the fast event) caches it in package.loaded for blink to find.
    luaInit = /* lua */ ''
      pcall(require, 'blink.cmp.fuzzy.rust')
      require('blink.cmp').setup(${lua.toLua cfg.config})
    '';
  };
}
