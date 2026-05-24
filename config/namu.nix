{ lib, ... }:

with lib;
let
  silent = {
    silent = true;
    noremap = true;
  };
  inline = code: lua.mkInline code;
in
{
  config = {
    namu = {
      enable = true;
      config = {
        watchtower.enable = true;
        namu_symbols.options.movement.close = [
          "<ESC>"
          "<C-c>"
        ];
        ui_select = {
          enable = true;
          options.movement = {
            next = [
              "<C-n>"
              "<DOWN>"
            ];
            previous = [
              "<C-p>"
              "<UP>"
            ];
            close = [
              "<ESC>"
              "<C-c>"
            ];
            select = [ "<CR>" ];
          };
        };
      };
    };

    keys.bindings = [
      {
        mode = "n";
        key = "<leader>n";
        action = inline "function() require('namu.namu_symbols').show() end";
        options = silent // {
          desc = "Document Symbols";
        };
      }
      {
        mode = "n";
        key = "<leader>N";
        action = inline "function() require('namu.namu_watchtower').show() end";
        options = silent // {
          desc = "Workspace Symbols (Watchtower)";
        };
      }
      {
        mode = "n";
        key = "<leader>d";
        action = inline "function() require('namu.namu_diagnostics').show_buffer_diagnostics() end";
        options = silent // {
          desc = "Document Diagnostics";
        };
      }
      {
        mode = "n";
        key = "<leader>D";
        action = inline "function() require('namu.namu_diagnostics').show_workspace_diagnostics() end";
        options = silent // {
          desc = "Workspace Diagnostics";
        };
      }
    ];

    keys.lsp = [
      {
        mode = "n";
        key = "gC";
        action = inline "function() require('namu.namu_callhierarchy').show_both_calls() end";
        options = silent // {
          desc = "Call Hierarchy (Namu)";
        };
      }
    ];
  };
}
