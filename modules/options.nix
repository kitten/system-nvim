{ lib, config, ... }:

with lib;
let
  cfg = config.vim;

  scopeOption =
    description:
    mkOption {
      default = { };
      type = types.attrsOf types.anything;
      inherit description;
    };

  # Vim option names are alphanumeric; safe as Lua identifiers.
  emit =
    scope: name: value:
    "vim.${scope}.${name} = ${lua.toLua value}";

  emitScope = scope: attrs: concatStringsSep "\n" (mapAttrsToList (emit scope) attrs);
in
{
  options.vim = {
    g = scopeOption "Global variables (vim.g.*).";
    o = scopeOption "Scalar options (vim.o.*).";
    opt = scopeOption "Lua-typed options for tables/lists (vim.opt.*).";
    wo = scopeOption "Window-local options (vim.wo.*).";
    bo = scopeOption "Buffer-local options (vim.bo.*).";
    go = scopeOption "Global-only options (vim.go.*).";
  };

  config.nvim.luaInit = concatStringsSep "\n\n" (
    filter (s: s != "") [
      (emitScope "g" cfg.g)
      (emitScope "o" cfg.o)
      (emitScope "opt" cfg.opt)
      (emitScope "wo" cfg.wo)
      (emitScope "bo" cfg.bo)
      (emitScope "go" cfg.go)
    ]
  );
}
