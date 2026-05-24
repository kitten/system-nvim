{ lib, ... }:

with lib;
let
  silent = {
    silent = true;
    noremap = true;
  };
  open = action: nvim.lazy "namu" action;
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
        action = open "require('namu.namu_symbols').show()";
        options = silent // {
          desc = "Document Symbols";
        };
      }
      {
        mode = "n";
        key = "<leader>N";
        action = open "require('namu.namu_watchtower').show()";
        options = silent // {
          desc = "Workspace Symbols (Watchtower)";
        };
      }
      {
        mode = "n";
        key = "<leader>d";
        action = open "require('namu.namu_diagnostics').show_buffer_diagnostics()";
        options = silent // {
          desc = "Document Diagnostics";
        };
      }
      {
        mode = "n";
        key = "<leader>D";
        action = open "require('namu.namu_diagnostics').show_workspace_diagnostics()";
        options = silent // {
          desc = "Workspace Diagnostics";
        };
      }
    ];

    keys.lsp = [
      {
        mode = "n";
        key = "gC";
        action = open "require('namu.namu_callhierarchy').show_both_calls()";
        options = silent // {
          desc = "Call Hierarchy (Namu)";
        };
      }
    ];
  };
}
