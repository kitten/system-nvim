{ config, ... }:

let
  palette = config.theme.palette;
in
{
  config.theme = {
    enable = true;
    background = "dark";

    highlights = with palette; {
      # :h hitest.vim
      ColorColumn.bg = cursor;
      Conceal.force = true;
      Cursor = {
        fg = black;
        bg = blue;
      };
      CursorIM.force = true;
      TermCursor.link = "Cursor";
      TermCursorNC.force = true;
      CursorColumn.bg = cursor;
      CursorLine.bg = gutter;
      Directory.fg = blue;
      ErrorMsg.fg = brightRed;
      WarningMsg.fg = yellow;
      VertSplit.fg = split;
      Folded = {
        bg = gutter;
        fg = muted;
      };
      FoldColumn.force = true;
      SignColumn.force = true;
      Search = {
        fg = blue;
        reverse = true;
      };
      LineNr = {
        fg = black;
        bg = black;
      };
      CursorLineNr = {
        fg = muted;
        bg = gutter;
        bold = true;
      };
      MatchParen = {
        fg = blue;
        underline = true;
      };
      ModeMsg.force = true;
      MoreMsg.force = true;
      NonText.fg = grey;
      Normal.fg = white;
      Question.fg = magenta;
      SpecialKey.fg = grey;

      StatusLine = {
        fg = white;
      };
      StatusLineNC.fg = muted;
      Title.fg = green;
      Visual.bg = cursor;
      VisualNOS.fg = grey;
      WildMenu = {
        fg = black;
        bg = blue;
      };
      NormalFloat.bg = element;
      TreesitterContext.bg = gutter;

      WinSeparator.fg = split;
      FloatBorder.link = "WinSeparator";

      Diff = {
        Add.bg = gutter;
        Change.bg = gutter;
        Delete.fg = muted;
        Text.force = true;
      };

      Pmenu = {
        base = {
          bg = gutter;
          blend = 5;
        };
        Sel = {
          fg = black;
          bg = blue;
        };
        Sbar.force = true;
        Thumb.bg = cursor;
      };

      Spell = {
        Bad = {
          sp = brightRed;
          undercurl = true;
        };
        Cap.fg = orange;
        Local.fg = orange;
        Rare.fg = orange;
      };

      TabLine = {
        base.fg = muted;
        Fill.force = true;
        Sel.fg = white;
      };

      GitSigns = {
        Add.fg = green;
        Change.fg = blue;
        Delete.fg = brightRed;
        Changedelete.strikethrough = true;
        Topdelete.link = "GitSignsDelete";
      };

      Diagnostic = {
        Warn.fg = yellow;
        Error.fg = brightRed;
        Info.fg = blue;
        Hint.fg = yellow;
        Ok.fg = green;
      };

      DiagnosticSign = {
        Warn.link = "DiagnosticWarn";
        Error.link = "DiagnosticError";
        Info.link = "DiagnosticInfo";
        Hint.link = "DiagnosticHint";
        Ok.link = "DiagnosticOk";
      };

      DiagnosticUnderline = {
        Error = {
          sp = brightRed;
          undercurl = true;
        };
        Warn = {
          sp = yellow;
          undercurl = true;
        };
        Info = {
          sp = blue;
          underdashed = true;
        };
        Hint = {
          sp = muted;
          underdotted = true;
        };
      };

      # :h w18
      Comment = {
        fg = muted;
        italic = true;
      };
      Constant.fg = pink;
      String.fg = green;
      Character.fg = green;
      Number.fg = orange;
      Float.link = "Number";
      Identifier.fg = white;
      Function.fg = blue;
      Statement.fg = magenta;
      Conditional.fg = red;
      Repeat.fg = magenta;
      Label.fg = magenta;
      Operator.fg = pink;
      Keyword.fg = magenta;
      Tag.fg = pink;
      Exception.fg = brightRed;
      PreProc.fg = yellow;
      Include.fg = brightBlue;
      Define.fg = magenta;
      Macro.fg = magenta;
      PreCondit.fg = yellow;
      Type.fg = aqua;
      StorageClass.fg = yellow;
      Structure.fg = yellow;
      Typedef.fg = yellow;
      Special.fg = orange;
      SpecialChar.fg = brightGreen;
      Delimiter.fg = cyan;
      Debug.force = true;
      Ignore.force = true;
      SpecialComment.fg = muted;
      Error.fg = brightRed;
      Todo.fg = brightBlue;
      GhostText.fg = grey;
      Underlined.underline = true;

      Boolean.link = "Conditional";

      # treesitter (builtin captures)
      "@constant".link = "Constant";
      "@constant.builtin".link = "Special";
      "@constant.macro".link = "Define";
      "@keyword.directive".link = "Define";
      "@string".link = "String";
      "@string.escape".link = "SpecialChar";
      "@string.special".link = "SpecialChar";
      "@number".link = "Number";
      "@number.float".link = "Float";
      "@function".link = "Function";
      "@function.builtin".link = "Special";
      "@function.macro".link = "Macro";
      "@function.method".link = "Function";
      "@function.parameter".link = "Function";
      "@variable.parameter".link = "Identifier";
      "@variable.parameter.builtin".link = "Special";
      "@attribute".link = "Macro";
      "@attribute.builtin".link = "Special";
      "@keyword.type".link = "Structure";
      "@label".link = "Label";
      "@operator".link = "Operator";
      "@keyword".link = "Keyword";
      "@variable".link = "Identifier";
      "@conditional".link = "Conditional";
      "@include".link = "Include";
      "@boolean".link = "Boolean";
      "@type".link = "Type";
      "@type.definition".link = "Typedef";
      "@module".link = "Identifier";
      "@keyword.debug".link = "Debug";
      "@tag".link = "Tag";
      "@tag.builtin".link = "Special";

      # treesitter (custom)
      "@comment.todo" = {
        fg = brightBlue;
        underline = true;
      };
      "@comment.error" = {
        fg = brightRed;
        underline = true;
      };
      "@comment.note" = {
        fg = magenta;
        underline = true;
      };
      "@constructor".link = "Structure";
      "@markup.raw".link = "@string";
      "@markup.list".link = "@operator";
      "@markup.strong".bold = true;
      "@markup.strikethrough".strikethrough = true;
      "@markup.underline".link = "Underlined";
      "@markup.italic".italic = true;
      "@markup.link.label".fg = cyan;
      "@markup.link.url" = {
        fg = brightBlue;
        underline = true;
      };
      "@markup.heading" = {
        fg = blue;
        bold = true;
      };
      "@string.special.url" = {
        fg = brightBlue;
        underline = true;
      };
      "@punctuation.bracket".link = "@operator";
      "@punctuation.delimiter".link = "Delimiter";
      "@punctuation.special".link = "SpecialChar";
      "@keyword.exception".link = "@conditional";
      "@keyword.return".link = "@conditional";
      "@keyword.conditional".link = "@conditional";
      "@keyword.repeat".link = "@conditional";
      "@keyword.operator".link = "@operator";
      "@keyword.import".link = "@include";
      "@property".fg = pink;
      "@variable.member".link = "@property";
      "@variable.builtin".link = "Special";
      "@type.builtin".link = "Special";

      # lsp (builtin semantic tokens)
      "@lsp.type.class".link = "Structure";
      "@lsp.type.comment".link = "Comment";
      "@lsp.type.decorator".link = "Function";
      "@lsp.type.enum".link = "Structure";
      "@lsp.type.enumMember".link = "Constant";
      "@lsp.type.function".link = "Function";
      "@lsp.type.interface".link = "Structure";
      "@lsp.type.macro".link = "Macro";
      "@lsp.type.method".link = "Function";
      "@lsp.type.namespace".link = "Structure";
      "@lsp.type.struct".link = "Structure";
      "@lsp.type.type".link = "Type";
      "@lsp.type.variable".link = "Identifier";

      # lsp (custom)
      "@lsp.type.typeParameter".link = "@variable";
      "@lsp.type.parameter".link = "@variable";
      "@lsp.type.property".link = "@variable.member";

      Glance = {
        ListNormal.bg = element;
        PreviewNormal.link = "GlanceListNormal";
        ListCursorLine.bg = gutter;
        PreviewCursorLine.link = "GlanceListCursorLine";
        WinBarFilename = {
          fg = white;
          bg = gutter;
        };
        WinBarTitle.link = "GlanceWinBarFilename";
        WinBarFilepath = {
          fg = muted;
          bg = gutter;
        };
        BorderTop = {
          fg = split;
          bg = gutter;
        };
        ListBorderBottom = {
          fg = split;
          bg = element;
        };
        PreviewBorderBottom.link = "GlanceListBorderBottom";
        ListFilepath.fg = muted;
        PreviewLineNr.fg = muted;
        Indent.link = "WinSeparator";
        ListMatch.link = "Visual";
        PreviewMatch.link = "Visual";
      };

      # statusline classes (active = StatusLine<Class>, inactive suffixed NC)
      StatusLineMode = {
        fg = black;
        bg = green;
        bold = true;
      };
      StatusLineModeNC = {
        fg = muted;
        bg = gutter;
      };
      StatusLineHigh = {
        fg = white;
        bg = gutter;
      };
      StatusLineHighNC = {
        fg = muted;
        bg = gutter;
      };
      StatusLineMed = {
        fg = muted;
      };
      StatusLineMedNC = {
        fg = muted;
      };
      StatusLineError = {
        fg = brightRed;
        bg = gutter;
        bold = true;
      };
      StatusLineErrorNC = {
        fg = muted;
        bg = gutter;
      };
      StatusLineWarning = {
        fg = orange;
        bg = gutter;
        bold = true;
      };
      StatusLineWarningNC = {
        fg = muted;
        bg = gutter;
      };
    };
  };
}
