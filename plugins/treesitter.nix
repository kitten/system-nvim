{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.treesitter;
in
{
  options.treesitter = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    languages = mkOption {
      default = [
        "astro"
        "bash"
        "c"
        "comment"
        "css"
        "git_rebase"
        "gitattributes"
        "gitcommit"
        "gitignore"
        "go"
        "graphql"
        "html"
        "javascript"
        "jsdoc"
        "json"
        "json5"
        "lua"
        "make"
        "markdown"
        "markdown_inline"
        "nix"
        "prisma"
        "regex"
        "rust"
        "sql"
        "svelte"
        "terraform"
        "tsx"
        "typescript"
        "vim"
        "vue"
        "yaml"
        "yuck"
        "zig"
      ];
      type = types.listOf types.str;
      description = ''
        Treesitter parser languages to bundle on the runtime path. Highlighting
        is enabled by a FileType autocmd (see config/autocmds.nix) using the
        Neovim 0.12 builtin vim.treesitter.start().
      '';
    };
  };

  # Register the parsers-only plugin so other modules can opt-in via plugins.treesitter.
  config.plugins.treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    g: map (name: g.${name}) cfg.languages
  );

  config.nvim = mkIf cfg.enable {
    plugins = [ config.plugins.treesitter ];
  };
}
