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
  version = "0.9.4";
  src = "${flake.outPath}";
  cfg = config.fff;

  libExt = if pkgs.stdenv.hostPlatform.isDarwin then "dylib" else "so";

  prebuiltLibs = {
    "aarch64-darwin" = {
      asset = "aarch64-apple-darwin.dylib";
      hash = "sha256-L3qdU/5VWiKmWFZhErjEiGrfMnXk6x3QTHQcx8hagPU=";
    };
    "x86_64-darwin" = {
      asset = "x86_64-apple-darwin.dylib";
      hash = "sha256-iVG9dOYt3yuQIxDxZEa8pRA8+URpO2AcFYKpANzaMkI=";
    };
    "aarch64-linux" = {
      asset = "aarch64-unknown-linux-gnu.so";
      hash = "sha256-BlosoMP9q0+7pjrKPxbiSk9ZA9+wYq1H09BaDaZRg08=";
    };
    "x86_64-linux" = {
      asset = "x86_64-unknown-linux-gnu.so";
      hash = "sha256-jNu+4fvRKdxnAzIqJAzv2AvG+R5qC7n+dKdY0HAPnxQ=";
    };
  };
  spec =
    prebuiltLibs.${pkgs.stdenv.hostPlatform.system}
      or (throw "fff.nvim: no prebuilt for ${pkgs.stdenv.hostPlatform.system}");

  fff-nvim-lib = pkgs.fetchurl {
    url = "https://github.com/dmtrKovalenko/fff.nvim/releases/download/v${version}/${spec.asset}";
    inherit (spec) hash;
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
        frecency = mkOption {
          default = { };
          type = types.attrsOf types.anything;
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
      ln -s ${fff-nvim-lib} target/release/libfff_nvim.${libExt}
    '';
    doInstallCheck = true;
    nvimRequireCheck = "fff";
    meta.homepage = "https://github.com/dmtrKovalenko/fff.nvim";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.fff ];

    # Eager: fff.setup is just `vim.g.fff = config`. fff's own plugin/fff.lua
    # reads vim.g.fff at UIEnter and caches; deferring our setup means UIEnter
    # snapshots empty config and our options are ignored.
    luaInit = /* lua */ ''
      require('fff').setup(${lua.toLua cfg.config})
    '';
  };
}
