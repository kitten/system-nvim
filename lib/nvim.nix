{ lib, ... }:

with lib;
{
  mkKeymapLua =
    keymaps:
    if keymaps != [ ] then
      /* lua */ ''
        do
          local __nix_binds = ${lua.toLua keymaps}
          for _, map in ipairs(__nix_binds) do
            vim.keymap.set(map.mode, map.key, map.action, map.options)
          end
        end
      ''
    else
      "";

  # Like mkKeymapLua, but stamps `options.buffer` with `bufExpr` at runtime.
  # Use inside attach callbacks where the buffer ID is only known at call time.
  mkBufferedKeymapLua =
    keymaps: bufExpr:
    if keymaps != [ ] then
      /* lua */ ''
        do
          local __buf = ${bufExpr}
          local __nix_binds = ${lua.toLua keymaps}
          for _, map in ipairs(__nix_binds) do
            local opts = vim.tbl_extend('force', map.options or {}, { buffer = __buf })
            vim.keymap.set(map.mode, map.key, map.action, opts)
          end
        end
      ''
    else
      "";

  # Inverse of mkBufferedKeymapLua — removes the same set of mappings from
  # `bufExpr`. pcall'd so missing entries don't error.
  mkBufferedKeymapDelLua =
    keymaps: bufExpr:
    if keymaps != [ ] then
      /* lua */ ''
        do
          local __buf = ${bufExpr}
          local __nix_binds = ${lua.toLua keymaps}
          for _, map in ipairs(__nix_binds) do
            local modes = type(map.mode) == 'table' and map.mode or { map.mode }
            for _, m in ipairs(modes) do
              pcall(vim.keymap.del, m, map.key, { buffer = __buf })
            end
          end
        end
      ''
    else
      "";

  # Plugin-side: emit a one-shot init function. Pair with `nvim.lazy` below.
  lazyInit = name: body: /* lua */ ''
    do
      local __done = false
      function _G.__lazy_${name}()
        if __done then return end
        __done = true
        ${body}
      end
    end
  '';

  # Keymap-side: wrap `action` (a Lua statement) so it runs the matching
  # `lazyInit` once before invoking the action body.
  lazy =
    name: action:
    lua.mkInline /* lua */ ''
      function() _G.__lazy_${name}(); ${action} end
    '';

  mkAutocmdLua =
    autocmds:
    if autocmds == [ ] then
      ""
    else
      concatStringsSep "\n" (
        map (
          ac:
          let
            opts = removeAttrs ac [ "event" ];
          in
          "vim.api.nvim_create_autocmd(${lua.toLua ac.event}, ${lua.toLua opts})"
        ) autocmds
      );
}
