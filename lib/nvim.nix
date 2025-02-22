{ lib, ... }:

with lib;
{
  mkKeymapLua = keymaps:
    if keymaps != [] then ''
      do
        local __nix_binds = ${lua.toLua keymaps}
        for i, map in ipairs(__nix_binds) do
          vim.keymap.set(map.mode, map.key, map.action, map.options)
        end
      end
    '' else "";
}
