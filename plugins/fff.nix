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
  flake = inputs.nvim-fff;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.fff;

  libExt = if pkgs.stdenv.hostPlatform.isDarwin then "dylib" else "so";

  fff-nvim-lib = pkgs.rustPlatform.buildRustPackage {
    inherit version src;
    pname = "fff-nvim-lib";
    buildAndTestSubdir = "crates/fff-nvim";
    cargoBuildFlags = [ "--lib" ];
    # fff-mcp lists `zlob` in its default features which (despite mcp not being
    # in fff-nvim's dep graph) flips on CARGO_FEATURE_ZLOB for fff-search via
    # workspace resolution and demands Zig. zlob is an optional Zig-backed
    # glob matcher; the pure-Rust globset fallback is fine.
    postPatch = ''
      substituteInPlace crates/fff-mcp/Cargo.toml \
        --replace-fail 'default = ["zlob"]' 'default = []'
    '';
    env = {
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

  layoutType = types.submoduleOpts {
    height = mkOption {
      default = null;
      type = types.nullOr (types.either types.int types.float);
    };
    width = mkOption {
      default = null;
      type = types.nullOr (types.either types.int types.float);
    };
    prompt_position = mkOption {
      default = null;
      type = types.nullOr (
        types.enum [
          "top"
          "bottom"
        ]
      );
    };
    preview_position = mkOption {
      default = null;
      type = types.nullOr (
        types.enum [
          "left"
          "right"
          "top"
          "bottom"
        ]
      );
    };
    preview_size = mkOption {
      default = null;
      type = types.nullOr (types.either types.int types.float);
    };
    show_scrollbar = mkOption {
      default = null;
      type = types.nullOr types.bool;
    };
  };
in
{
  options.fff = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    config = mkOption {
      default = { };
      type = types.submoduleOpts {
        layout = mkOption {
          default = { };
          type = layoutType;
        };
        max_results = mkOption {
          default = null;
          type = types.nullOr types.int;
        };
        max_threads = mkOption {
          default = null;
          type = types.nullOr types.int;
        };
        lazy_sync = mkOption {
          default = null;
          type = types.nullOr types.bool;
        };
        # default fff title is "FFFiles"; suppress it
        title = mkOption {
          default = "";
          type = types.str;
        };
        keymaps = mkOption {
          default = { };
          type = types.attrsOf types.anything;
        };
        hl = mkOption {
          default = { };
          type = types.attrsOf types.anything;
        };
      };
    };
  };

  config.plugins.fff = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "fff.nvim";
    # fff.nvim looks for the matcher at <plugin>/target/release/libfff_nvim.<ext>
    preInstall = ''
      mkdir -p target/release
      ln -s ${fff-nvim-lib}/lib/libfff_nvim.${libExt} target/release/libfff_nvim.${libExt}
    '';
    doInstallCheck = true;
    nvimRequireCheck = "fff";
    meta.homepage = "https://github.com/dmtrKovalenko/fff.nvim";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.fff ];

    # Pre-warm the rust submodule (same loader-cache concern as blink-cmp).
    luaInit = /* lua */ ''
      pcall(require, 'fff.rust')
      require('fff').setup(${lua.toLua cfg.config})
    '';
  };
}
