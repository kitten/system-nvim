{ lib, ... }:

with lib;
let
  silent = {
    silent = true;
    noremap = true;
  };
  inline = code: lua.mkInline code;

  # Build per-severity maps (text + texthl). Keys are raw Lua expressions
  # referencing vim.diagnostic.severity.* enums.
  bySeverity =
    attrs:
    listToAttrs (
      mapAttrsToList (sev: value: {
        name = "__rawKey__vim.diagnostic.severity.${sev}";
        inherit value;
      }) attrs
    );

  diagnosticConfig = {
    underline = true;
    update_in_insert = false;
    severity_sort = true;

    signs = {
      text = bySeverity {
        ERROR = "●";
        WARN = "◐";
        INFO = "○";
        HINT = "";
      };
      texthl = bySeverity {
        ERROR = "DiagnosticSignError";
        WARN = "DiagnosticSignWarn";
        INFO = "DiagnosticSignInfo";
        HINT = "DiagnosticSignHint";
      };
    };

    virtual_text = {
      severity = {
        min = inline "vim.diagnostic.severity.WARN";
      };
      source = "if_many";
    };

    float = {
      show_header = true;
      source = "if_many";
      border = "rounded";
      focusable = false;
      severity_sort = true;
    };
  };
in
{
  config = {
    nvim.luaInit = /* lua */ ''
      vim.diagnostic.config(${lua.toLua diagnosticConfig})
    '';

    keys.bindings = [
      {
        mode = "n";
        key = "gk";
        action = inline "vim.diagnostic.open_float";
        options = silent // {
          desc = "Show Diagnostic";
        };
      }
      {
        mode = "n";
        key = "[d";
        action = inline "vim.diagnostic.goto_prev";
        options = silent // {
          desc = "Previous Diagnostic";
        };
      }
      {
        mode = "n";
        key = "]d";
        action = inline "vim.diagnostic.goto_next";
        options = silent // {
          desc = "Next Diagnostic";
        };
      }
    ];
  };
}
