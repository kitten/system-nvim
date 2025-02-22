{ pkgs, lib, config, plugins, inputs, ... }:

with lib;
let
  flake = inputs.nvim-golden-size;
  version = "${flake.rev}";
  src = "${flake.outPath}";
  cfg = config.golden-size;
in {
  options.golden-size = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    ignoreFloatWindows = mkOption {
      default = true;
      type = types.bool;
    };

    ignoreByWindowFlag = mkOption {
      default = true;
      type = types.bool;
    };

    ignoreFiletypes = mkOption {
      default = [];
      type = types.listOf types.str;
      apply = v: listToAttrs (map (ft: { name = ft; value = ft; }) v);
    };
  };

  config.plugins.golden-size = pkgs.vimUtils.buildVimPlugin {
    inherit src version;
    pname = "nvim-golden-size";
    nvimRequireCheck = [ "golden_size" ];
    meta.homepage = "https://github.com/dm1try/golden_size/";
  };

  config.nvim = mkIf cfg.enable {
    plugins = [ plugins.golden-size ];

    luaInit = let
      ignore_filetypes = lua.mkInline /*lua*/''
        function ignore_filetypes()
          local ignore = ${lua.toLua cfg.ignoreFiletypes}
          local ft = vim.api.nvim_buf_get_option(0, 'filetype')
          if ignore[ft] then
            return 1
          end
        end
      '';
      ignore_float_windows = lua.mkInline /*lua*/''require('golden_size').ignore_float_windows'';
      ignore_by_window_flag = lua.mkInline /*lua*/''require('golden_size').ignore_by_window_flag'';
      callbacks = 
        (optionals cfg.ignoreFloatWindows [[ ignore_float_windows ]])
        ++ (optionals cfg.ignoreByWindowFlag [[ ignore_by_window_flag ]])
        ++ (optionals (cfg.ignoreFiletypes != {}) [[ ignore_filetypes ]]);
    in /*lua*/''
      require('golden_size').set_ignore_callbacks(${lua.toLua callbacks})
    '';
  };
}
