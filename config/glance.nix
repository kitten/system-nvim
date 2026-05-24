{ lib, ... }:

with lib;
let
  silent = {
    silent = true;
    noremap = true;
  };

  glanceAction =
    scope: fallback:
    nvim.lazy "glance" /* lua */ ''
      local ok, glance = pcall(require, 'glance')
      if ok then glance.open('${scope}') else vim.lsp.buf.${fallback}() end
    '';
in
{
  config = {
    glance = {
      enable = true;

      config = {
        height = 18;
        border = {
          enable = false;
        };
        list = {
          position = "left";
          width = 0.33;
        };
        theme = {
          enable = true;
          mode = "auto";
        };
        preview_win_opts = {
          cursorline = false;
          number = false;
          wrap = true;
        };
        mappings =
          let
            close = lua.mkInline "require('glance').actions.close";
          in
          {
            list = {
              "<C-c>" = close;
            };
            preview = {
              "<C-c>" = close;
            };
          };
      };
    };

    keys.lsp = [
      {
        mode = "n";
        key = "gr";
        action = glanceAction "references" "references";
        options = silent // {
          desc = "References (Glance)";
        };
      }
      {
        mode = "n";
        key = "gD";
        action = glanceAction "definitions" "definition";
        options = silent // {
          desc = "Definitions (Glance)";
        };
      }
      {
        mode = "n";
        key = "gY";
        action = glanceAction "type_definitions" "type_definition";
        options = silent // {
          desc = "Type Definitions (Glance)";
        };
      }
      {
        mode = "n";
        key = "gI";
        action = glanceAction "implementations" "implementation";
        options = silent // {
          desc = "Implementations (Glance)";
        };
      }
    ];
  };
}
