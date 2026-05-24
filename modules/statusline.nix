{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.statusline;

  sectionType = types.submodule {
    options = {
      class = mkOption {
        type = types.str;
        description = "Highlight class. Resolves to StatusLine<Class> / StatusLine<Class>NC.";
      };
      item = mkOption {
        type = types.str;
        description = "Provider name (key in cfg.providers).";
      };
      hide = mkOption {
        default = null;
        type = types.nullOr types.int;
        description = "Window-width threshold below which the section is hidden.";
      };
    };
  };

  defaultProviders = {
    mode = /* lua */ ''
      function()
        local m = vim.api.nvim_get_mode().mode
        local map = {
          n = 'NORMAL', i = 'INSERT', v = 'VISUAL', V = 'V-LINE',
          [vim.api.nvim_replace_termcodes('<C-V>', true, true, true)] = 'V-BLOCK',
          c = 'COMMAND', R = 'REPLACE', t = 'TERMINAL', s = 'SELECT', S = 'S-LINE',
        }
        return map[m] or m:upper()
      end
    '';

    filename = /* lua */ ''
      function()
        return vim.fn.expand('%:~:.')
      end
    '';

    git_status = /* lua */ ''
      function()
        local b = vim.b
        if not b.gitsigns_status_dict then return "" end
        local d = b.gitsigns_status_dict
        local function hi(group, str)
          return str ~= "" and string.format('%%#%s#%s', group, str) or ""
        end
        return table.concat({
          hi('GitSignsAdd',        string.format(' %d', d.added or 0)),
          hi('GitSignsChange',     string.format(' %d', d.changed or 0)),
          hi('GitSignsDelete',     string.format(' %d', d.removed or 0)),
          hi('DiagnosticSignInfo', b.gitsigns_head and string.format('( %s)', b.gitsigns_head) or ""),
        }, ' ')
      end
    '';

    diag_error = /* lua */ ''
      function()
        local n = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        return n > 0 and string.format(' %d', n) or ""
      end
    '';

    diag_warn = /* lua */ ''
      function()
        local n = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        return n > 0 and string.format(' %d', n) or ""
      end
    '';

    filetype = /* lua */ ''
      function()
        return vim.bo.filetype ~= "" and string.format('  %s', vim.bo.filetype) or ""
      end
    '';

    progress = /* lua */ ''
      function()
        local blocks = { '█','▇','▆','▅','▄','▃','▂','▁',' ' }
        local nbline = vim.fn.line('$')
        if nbline == 1 then return "" end
        local line = vim.fn.line('.')
        local block = blocks[math.ceil(line / (nbline / 9))]
        return string.format('%s%d/%d %s',
          string.rep('·', #tostring(nbline) - #tostring(line)),
          line, nbline, block)
      end
    '';
  };
in
{
  options.statusline = {
    enable = mkEnableOption "hand-rolled statusline";

    providers = mkOption {
      default = { };
      type = types.attrsOf types.str;
      description = ''
        Extra provider functions, name → raw Lua function code.
        Merged with built-ins (mode, filename, git_status, diag_error,
        diag_warn, filetype, progress).
      '';
    };

    sections = mkOption {
      default = [ ];
      type = types.listOf (types.either types.str sectionType);
      description = ''
        Ordered list of sections. Each entry is either a literal string
        (passed through verbatim, e.g. "%<", "%=") or a section object
        { class, item, hide? }.
      '';
    };
  };

  config = mkIf cfg.enable {
    # per-window statusline (the runtime emits a separate NC variant)
    vim.o.laststatus = 2;

    autocmds = [
      {
        event = [
          "ModeChanged"
          "WinEnter"
          "BufEnter"
        ];
        desc = "Redraw statusline on focus / mode change";
        callback = lua.mkInline "function() vim.cmd.redrawstatus() end";
      }
    ];

    nvim.luaInit =
      let
        allProviders = defaultProviders // cfg.providers;
        providersChunk = concatStringsSep ",\n  " (
          mapAttrsToList (name: code: "${name} = ${code}") allProviders
        );
        capitalise = s: (toUpper (substring 0 1 s)) + (substring 1 (-1) s);
        # Pre-compute the highlight group at Nix eval time
        sectionsRendered = map (
          s: if isString s then s else s // { _group = "StatusLine" + (capitalise s.class); }
        ) cfg.sections;
      in
      /* lua */ ''
        do
          local P = {
            ${providersChunk}
          }

          local SECTIONS = ${lua.toLua sectionsRendered}

          local function hi(group, str)
            return str ~= "" and string.format('%%#%s#%s%%*', group, str) or ""
          end

          local function render(is_active)
            local nc = is_active and "" or "NC"
            local width = vim.api.nvim_win_get_width(0)
            local out = {}
            local prev_class
            for _, sec in ipairs(SECTIONS) do
              if type(sec) == 'string' then
                table.insert(out, sec)
                prev_class = nil
              elseif not (sec.hide and width < sec.hide) then
                local provider = P[sec.item]
                local content = provider and provider() or ""
                if content ~= "" then
                  local group = sec._group .. nc
                  if prev_class == sec.class then
                    out[#out] = out[#out]:gsub('%%%*$', "") .. ' ' .. content .. '%*'
                  else
                    table.insert(out, hi(group, ' ' .. content .. ' '))
                  end
                  prev_class = sec.class
                end
              end
            end
            return table.concat(out)
          end

          function _G.statusline_render()
            local cur = vim.api.nvim_get_current_win()
            return render(cur == vim.g.statusline_winid)
          end

          vim.o.statusline = '%!v:lua.statusline_render()'
        end
      '';
  };
}
