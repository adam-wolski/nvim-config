local colors = {
  none = "NONE",

  white = "#f9f9f9",
  whitepp = "#fefefe",
  gray = "#dedede",
  graypp = "#e3e3e3",
  darkgray = "#333333",
  darkgraypp = "#383838",
  darkgraylighter = "#404040",
  darkgraylighterpp = "#454545",
  red = "#F44336",

  yellow = "#b58900",
  orange = "#cb4b16",
  solar_red = "#dc322f",
  magenta = "#d33682",
  violet = "#6c71c4",
  blue = "#268bd2",
  cyan = "#2aa198",
  green = "#719e07",
}

colors.comment = colors.cyan
colors.constant = colors.cyan
colors.identifier = colors.blue
colors.statement = colors.green
colors.preproc = colors.orange
colors.type = colors.yellow
colors.special = colors.solar_red
colors.underlined = colors.violet
colors.error = colors.solar_red
colors.todo = colors.solar_red

colors.bg0 = colors.darkgray
colors.bgl = colors.darkgraylighter
colors.bgL = colors.darkgraylighterpp
colors.bgd = colors.darkgraypp
colors.bgD = colors.darkgray

colors.fgb = colors.darkgray
colors.fge = colors.red
colors.fg0 = colors.white
colors.fg1 = colors.whitepp
colors.fg2 = colors.graypp
colors.fg3 = colors.gray
colors.fgl = colors.darkgraylighter
colors.fgL = colors.darkgraylighterpp
colors.fgd = colors.darkgraypp
colors.fgD = colors.darkgray

local groups = {
  Normal = { bg = colors.bg0 },
  NormalFloat = { bg = colors.bgd },

  Comment = { fg = colors.comment, bold = true, italic = true },
  String = { fg = colors.constant },
  Constant = { fg = colors.constant },
  Function = { fg = colors.identifier },
  Identifier = { fg = colors.identifier },
  Statement = { fg = colors.statement },
  PreProc = { fg = colors.preproc },
  Type = { fg = colors.type },
  Special = { fg = colors.special },
  SpecialComment = { fg = colors.comment, bold = true, italic = true },
  Underlined = { fg = colors.underlined },
  Ignore = { fg = colors.fgb },
  Error = { fg = colors.error, bold = true },
  Todo = { fg = colors.todo, bold = true },

  SpecialKey = { fg = colors.type, bold = true },
  NonText = { fg = colors.fgL, bold = true },
  StatusLine = { fg = colors.fg1, reverse = true },
  StatusLineNC = { fg = colors.fg3, reverse = true },
  Visual = { fg = colors.fg0, reverse = true },
  Directory = { fg = colors.identifier },
  ErrorMsg = { fg = colors.error, reverse = true },
  IncSearch = { fg = colors.preproc, standout = true },
  Search = { fg = colors.type, reverse = true },
  MoreMsg = { fg = colors.identifier },
  ModeMsg = { fg = colors.identifier },
  LineNr = { fg = colors.fg2 },
  Question = { fg = colors.cyan, bold = true },
  VertSplit = { fg = colors.fg3, bg = colors.bg0 },
  Title = { fg = colors.preproc, bold = true },
  VisualNOS = { bg = colors.bgd, standout = true },
  WarningMsg = { fg = colors.error, bold = true },
  WildMenu = { fg = colors.fg2, bg = colors.bgl },
  Folded = { fg = colors.fg0, bold = true, italic = true },
  FoldColumn = { fg = colors.fg0, bg = colors.bgd },
  DiffAdd = { fg = colors.green, bg = colors.bgd, bold = true, sp = colors.green },
  DiffChange = { fg = colors.yellow, bg = colors.bgd, bold = true, sp = colors.yellow },
  DiffDelete = { fg = colors.solar_red, bg = colors.bgd, bold = true },
  DiffText = { fg = colors.blue, bg = colors.bgd, bold = true, sp = colors.blue },
  SignColumn = { fg = colors.fg0 },
  Conceal = { fg = colors.identifier },
  Pmenu = { fg = colors.fg0, bg = colors.bgd },
  PmenuSel = { fg = colors.fg2, bg = colors.bgl },
  PmenuSbar = { fg = colors.fgl, bg = colors.bg0 },
  PmenuThumb = { fg = colors.fg0, bg = colors.bgD },
  TabLine = { fg = colors.fg0, bg = colors.bgd, underline = true },
  TabLineFill = { fg = colors.fg0, bg = colors.bgd, underline = true },
  TabLineSel = { fg = colors.fg2, bg = colors.bgl, underline = true },
  CursorColumn = { bg = colors.bgl },
  CursorLine = { bg = colors.bgl },
  ColorColumn = { bg = colors.bgd },
  Cursor = { bg = colors.solar_red, reverse = true },
  lCursor = { link = "Cursor" },
  MatchParen = { fg = colors.solar_red, bg = colors.bgd, bold = true },

  vimVar = { link = "Identifier" },
  vimFunc = { link = "Function" },
  vimUserFunc = { link = "Function" },
  helpSpecial = { link = "Special" },
  vimSet = { link = "Normal" },
  vimSetEqual = { link = "Normal" },
  vimCommentString = { fg = colors.violet },
  vimCommand = { fg = colors.type },
  vimCmdSep = { fg = colors.identifier, bold = true },
  helpExample = { fg = colors.fg1 },
  helpOption = { fg = colors.cyan },
  helpNote = { fg = colors.magenta },
  helpVim = { fg = colors.magenta },
  helpHyperTextJump = { fg = colors.identifier, underline = true },
  helpHyperTextEntry = { fg = colors.green },
  vimIsCommand = { fg = colors.fg3 },
  vimSynMtchOpt = { fg = colors.type },
  vimSynType = { fg = colors.cyan },
  vimHiLink = { fg = colors.identifier },
  vimHiGroup = { fg = colors.identifier },
  vimGroup = { fg = colors.identifier, underline = true },

  diffAdded = { link = "Statement" },
  diffLine = { link = "Identifier" },

  gitcommitComment = { fg = colors.fg2, italic = true },
  gitcommitUntracked = { link = "gitcommitComment" },
  gitcommitDiscarded = { link = "gitcommitComment" },
  gitcommitSelected = { link = "gitcommitComment" },
  gitcommitUnmerged = { fg = colors.green, bold = true },
  gitcommitOnBranch = { fg = colors.fg2, bold = true },
  gitcommitBranch = { fg = colors.magenta, bold = true },
  gitcommitNoBranch = { link = "gitcommitBranch" },
  gitcommitDiscardedType = { fg = colors.solar_red },
  gitcommitSelectedType = { fg = colors.green },
  gitcommitHeader = { fg = colors.fg2 },
  gitcommitUntrackedFile = { fg = colors.cyan, bold = true },
  gitcommitDiscardedFile = { fg = colors.solar_red, bold = true },
  gitcommitSelectedFile = { fg = colors.green, bold = true },
  gitcommitUnmergedFile = { fg = colors.type, bold = true },
  gitcommitFile = { fg = colors.fg0, bold = true },
  gitcommitDiscardedArrow = { link = "gitcommitDiscardedFile" },
  gitcommitSelectedArrow = { link = "gitcommitSelectedFile" },
  gitcommitUnmergedArrow = { link = "gitcommitUnmergedFile" },

  htmlTag = { fg = colors.fg2 },
  htmlEndTag = { fg = colors.fg2 },
  htmlTagN = { fg = colors.fg1, bold = true },
  htmlTagName = { fg = colors.identifier, bold = true },
  htmlSpecialTagName = { fg = colors.identifier, italic = true },
  htmlArg = { fg = colors.fg3 },
  javaScript = { fg = colors.type },

  perlHereDoc = { fg = colors.fg1, bg = colors.bg0 },
  perlVarPlain = { fg = colors.type, bg = colors.bg0 },
  perlStatementFileDesc = { fg = colors.cyan, bg = colors.bg0 },

  texStatement = { fg = colors.cyan, bg = colors.bg0 },
  texMathZoneX = { fg = colors.type, bg = colors.bg0 },
  texMathMatcher = { fg = colors.type, bg = colors.bg0 },
  texRefLabel = { fg = colors.type, bg = colors.bg0 },

  cPreCondit = { fg = colors.preproc },

  VarId = { fg = colors.identifier },
  ConId = { fg = colors.type },
  hsImport = { fg = colors.magenta },
  hsString = { fg = colors.fg3 },
  hsStructure = { fg = colors.cyan },
  hs_hlFunctionName = { fg = colors.identifier },
  hsStatement = { fg = colors.cyan },
  hsImportLabel = { fg = colors.cyan },
  hs_OpFunctionName = { fg = colors.type },
  hs_DeclareFunction = { fg = colors.preproc },
  hsVarSym = { fg = colors.cyan },
  hsType = { fg = colors.type },
  hsTypedef = { fg = colors.cyan },
  hsModuleName = { fg = colors.green, underline = true },
  hsModuleStartLabel = { fg = colors.magenta },
  hsImportParams = { link = "Delimiter" },
  hsDelimTypeExport = { link = "Delimiter" },
  hsModuleWhereLabel = { link = "hsModuleStartLabel" },
  hsNiceOperator = { fg = colors.cyan },
  hsniceoperator = { fg = colors.cyan },

  rustDerive = { fg = colors.preproc, bg = colors.bg0 },
  rustStorage = { fg = colors.type, bg = colors.bg0 },
  rustReservedKeyword = { fg = colors.type, bg = colors.bg0 },

  pythonComment = { fg = colors.type, bg = colors.bg0, bold = true },

  ClangdInactiveCode = { fg = colors.comment, bold = true, italic = true },
  ClangdClass = { fg = colors.type, bg = colors.bg0, italic = true },
  ClangdEnum = { fg = colors.green, bg = colors.bg0 },
  ClangdTypedef = { fg = colors.type, bg = colors.bg0 },
  ClangdTemplateParameter = { fg = colors.type, bg = colors.bg0, bold = true },
  ClangdFunction = { fg = colors.identifier, bg = colors.bg0 },
  ClangdMemberFunction = { fg = colors.identifier, bg = colors.bg0, italic = true },
  ClangdStaticMemberFunction = { fg = colors.identifier, bg = colors.bg0 },
  ClangdEnumConstant = { fg = colors.cyan, bg = colors.bg0 },
  ClangdMacro = { fg = colors.solar_red, bg = colors.bg0 },
  ClangdNamespace = { fg = colors.green, bg = colors.bg0 },
  ClangdLocalVariable = { bg = colors.bg0 },
  ClangdVariable = { fg = colors.magenta, bg = colors.bg0 },
  ClangdParameter = { fg = colors.fg0, bg = colors.bg0 },
  ClangdField = { fg = colors.preproc, bg = colors.bg0, italic = true },
  ClangdStaticField = { fg = colors.preproc, bg = colors.bg0, italic = true },
  ClangdPrimitive = { fg = colors.type, bg = colors.bg0 },
  ClangdConcept = { fg = colors.solar_red, bg = colors.yellow },
  ClangdDependentName = { fg = colors.preproc, bg = colors.bg0, bold = true },
  ClangdDependentType = { fg = colors.type, bg = colors.bg0, bold = true },

  ["@type.builtin.hlsl"] = { link = "Type" },
  ["@constructor.hlsl"] = { link = "Function" },

  ["@variable"] = { bg = colors.bg0 },
  ["@lsp.type.variable"] = { bg = colors.bg0 },
  ["@lsp.mod.mutable"] = { bg = colors.bg0, underline = true },
  ["@lsp.mod.constant"] = { fg = colors.magenta, bg = colors.bg0 },
  ["@lsp.typemod.variable.static.rust"] = { fg = colors.magenta, bg = colors.bg0 },
  ["@lsp.type.macro"] = { fg = colors.preproc },
  ["@lsp.type.static"] = { fg = colors.magenta, bg = colors.bg0 },
  ["@lsp.type.enumMember"] = { fg = colors.magenta, bg = colors.bg0 },
  ["@lsp.type.property"] = { fg = colors.preproc, bg = colors.bg0, italic = true },
  ["@field"] = { fg = colors.preproc, bg = colors.bg0, italic = true },
  ["@lsp.type.method"] = { fg = colors.identifier, bg = colors.bg0, italic = true },
  ["@lsp.type.parameter"] = { fg = colors.fg0, bg = colors.bg0 },
  ["@lsp.type.namespace"] = { fg = colors.green, bg = colors.bg0 },
  ["@namespace"] = { fg = colors.green, bg = colors.bg0 },
  ["@lsp.type.keyword"] = { fg = colors.type, bg = colors.bg0 },
  ["@lsp.type.struct"] = { fg = colors.type, bg = colors.bg0, italic = true },
  ["@lsp.type.typeAlias.rust"] = { fg = colors.type, bg = colors.bg0, italic = true },
  ["@lsp.type.enum"] = { fg = colors.cyan, bg = colors.bg0 },
  ["@lsp.type.interface"] = { fg = colors.type, bg = colors.bg0, bold = true },
  ["@lsp.type.decorator"] = { fg = colors.solar_red, bg = colors.bg0 },
  ["@lsp.type.generic"] = { fg = colors.solar_red, bg = colors.bg0 },
  ["@lsp.type.deriveHelper"] = { fg = colors.solar_red, bg = colors.bg0 },
  ["@lsp.type.derive"] = { fg = colors.type, bg = colors.bg0, bold = true },

  ["@lsp.typemod.variable.globalScope.c"] = { link = "@lsp.type.enumMember.c" },
  ["@property.c"] = { link = "@lsp.type.variable.c" },
  ["@lsp.type.property.c"] = { link = "@lsp.type.variable.c" },
  ["@operator.c"] = { link = "@lsp.type.property" },
  ["@punctuation.delimiter.c"] = { link = "@lsp.type.property" },
}

local is_gui = vim.fn.has("gui_running") == 1

if is_gui then
  groups.SpellBad = { fg = colors.fg0, undercurl = true, sp = colors.solar_red }
  groups.SpellCap = { fg = colors.fg0, undercurl = true, sp = colors.violet }
  groups.SpellRare = { fg = colors.fg0, undercurl = true, sp = colors.cyan }
  groups.SpellLocal = { fg = colors.fg0, undercurl = true, sp = colors.yellow }
else
  groups.SpellBad = { fg = colors.fg0, bg = colors.solar_red, undercurl = true }
  groups.SpellCap = { fg = colors.fg0, bg = colors.violet, undercurl = true }
  groups.SpellRare = { fg = colors.fg0, bg = colors.cyan, undercurl = true }
  groups.SpellLocal = { fg = colors.fg0, bg = colors.yellow, undercurl = true }
end

local function apply()
  vim.cmd("highlight clear")

  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.o.background = "dark"
  vim.g.colors_name = "nugl"

  vim.g.hs_highlight_boolean = 1
  vim.g.hs_highlight_delimiters = 1

  vim.g.terminal_color_foreground = "#282828"
  vim.g.terminal_color_background = "#eeeeee"
  vim.g.terminal_color_0 = "#282828"
  vim.g.terminal_color_1 = "#f43753"
  vim.g.terminal_color_2 = "#c9d05c"
  vim.g.terminal_color_3 = "#ffc24b"
  vim.g.terminal_color_4 = "#b3deef"
  vim.g.terminal_color_5 = "#d3b987"
  vim.g.terminal_color_6 = "#73cef4"
  vim.g.terminal_color_7 = "#eeeeee"
  vim.g.terminal_color_8 = "#1d1d1d"
  vim.g.terminal_color_9 = "#f43753"
  vim.g.terminal_color_10 = "#c9d05c"
  vim.g.terminal_color_11 = "#ffc24b"
  vim.g.terminal_color_12 = "#b3deef"
  vim.g.terminal_color_13 = "#d3b987"
  vim.g.terminal_color_14 = "#73cef4"
  vim.g.terminal_color_15 = "#ffffff"

  for group, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

apply()

return {
  colors = colors,
  groups = groups,
  apply = apply,
}
