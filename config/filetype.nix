{
  config.filetype = {
    plugin = true;
    indent = true;

    extension = {
      mdx = "markdown";
      astro = "astro";
      envrc = "bash";
    };

    pattern = {
      ".*/%.vscode/.*%.json" = "json5";
    };
  };
}
