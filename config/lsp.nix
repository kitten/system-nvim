{ pkgs, lib, ... }:

with lib;
let
  bin = pkg: name: "${pkg}/bin/${name}";

  silent = {
    silent = true;
    noremap = true;
  };
  inline = code: lua.mkInline code;
in
{
  config = {
    lsp.servers = {
      ts_ls = {
        cmd = [
          (bin pkgs.typescript-language-server "typescript-language-server")
          "--stdio"
        ];
        filetypes = [
          "javascript"
          "javascriptreact"
          "javascript.jsx"
          "typescript"
          "typescriptreact"
          "typescript.tsx"
        ];
        root_markers = [
          "tsconfig.json"
          "package.json"
          "jsconfig.json"
          ".git"
        ];
        init_options = {
          hostInfo = "neovim";
          disableAutomaticTypingAcquisition = true;
          preferences = {
            importModuleSpecifierPreference = "project-relative";
          };
        };
      };

      eslint = {
        cmd = [
          (bin pkgs.vscode-eslint-language-server "vscode-eslint-language-server")
          "--stdio"
        ];
        filetypes = [
          "javascript"
          "javascriptreact"
          "javascript.jsx"
          "typescript"
          "typescriptreact"
          "typescript.tsx"
          "vue"
          "svelte"
          "astro"
        ];
        root_markers = [
          ".eslintrc"
          ".eslintrc.js"
          ".eslintrc.cjs"
          ".eslintrc.json"
          "eslint.config.js"
          "eslint.config.mjs"
          "eslint.config.cjs"
          "package.json"
          ".git"
        ];
        settings = {
          rulesCustomizations = [
            {
              rule = "prettier/prettier";
              severity = "off";
            }
            {
              rule = "sort-keys";
              severity = "off";
            }
            {
              rule = "quotes";
              severity = "off";
            }
            {
              rule = "max-len";
              severity = "off";
            }
            {
              rule = "no-tabs";
              severity = "off";
            }
          ];
        };
      };

      cssls = {
        cmd = [
          (bin pkgs.vscode-css-language-server "vscode-css-language-server")
          "--stdio"
        ];
        filetypes = [
          "css"
          "scss"
          "less"
        ];
      };

      html = {
        cmd = [
          (bin pkgs.vscode-html-language-server "vscode-html-language-server")
          "--stdio"
        ];
        filetypes = [ "html" ];
      };

      jsonls = {
        cmd = [
          (bin pkgs.vscode-json-language-server "vscode-json-language-server")
          "--stdio"
        ];
        filetypes = [
          "json"
          "jsonc"
        ];
      };

      rust_analyzer = {
        cmd = [ (bin pkgs.rust-analyzer "rust-analyzer") ];
        filetypes = [ "rust" ];
        settings = {
          "rust-analyzer" = {
            assist = {
              importGranularity = "module";
              importPrefix = "self";
            };
            cargo = {
              loadOutDirsFromCheck = true;
            };
            procMacro = {
              enable = true;
            };
          };
        };
      };

      terraformls = {
        cmd = [
          (bin pkgs.terraform-ls "terraform-ls")
          "serve"
        ];
        filetypes = [
          "terraform"
          "terraform-vars"
        ];
      };

      zls = {
        cmd = [ (bin pkgs.zls "zls") ];
        filetypes = [
          "zig"
          "zir"
        ];
        settings = {
          zls = {
            zig_exe_path = bin pkgs.zig "zig";
          };
        };
      };
    };

    keys.lsp = [
      {
        mode = "n";
        key = "gd";
        action = inline "vim.lsp.buf.definition";
        options = silent // {
          desc = "Go to definition";
        };
      }
      {
        mode = "n";
        key = "gy";
        action = inline "vim.lsp.buf.type_definition";
        options = silent // {
          desc = "Go to type definition";
        };
      }
      {
        mode = "n";
        key = "gi";
        action = inline "vim.lsp.buf.implementation";
        options = silent // {
          desc = "Go to implementation";
        };
      }
      {
        mode = "n";
        key = "gn";
        action = inline "vim.lsp.buf.rename";
        options = silent // {
          desc = "Rename";
        };
      }
      {
        mode = "n";
        key = "gf";
        action = inline "vim.lsp.buf.code_action";
        options = silent // {
          desc = "Code Actions";
        };
      }
      {
        mode = "n";
        key = "K";
        action = inline "vim.lsp.buf.hover";
        options = silent // {
          desc = "Hover";
        };
      }
      {
        mode = "n";
        key = "<C-k>";
        action = inline "vim.lsp.buf.signature_help";
        options = silent // {
          desc = "Signature Help";
        };
      }
    ];

    # Register CursorHold/CursorMoved buffer-locally on LspAttach so the
    # autocmds only exist on buffers with a client (avoids dispatch on
    # every cursor move in non-LSP buffers).
    lsp.onAttach = /* lua */ ''
      vim.api.nvim_create_autocmd('CursorHold', {
        buffer = buf,
        desc = 'LSP document_highlight',
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = buf,
        desc = 'LSP clear_references',
        callback = vim.lsp.buf.clear_references,
      })
    '';

    # vim.lsp.with is deprecated in 0.11+; wrap vim.lsp.buf.hover instead
    nvim.luaInit = /* lua */ ''
      do
        local original_hover = vim.lsp.buf.hover
        vim.lsp.buf.hover = function(opts)
          opts = vim.tbl_deep_extend('force', {
            max_width  = math.max(math.floor(vim.o.columns * 0.7), 100),
            max_height = math.max(math.floor(vim.o.lines * 0.3), 30),
          }, opts or {})
          return original_hover(opts)
        end
      end
    '';
  };
}
