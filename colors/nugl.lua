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

  Comment = { fg = colors.cyan, bold = true, italic = true },
  String = { fg = colors.cyan },
  Constant = { fg = colors.cyan },
  Function = { fg = colors.blue },
  Identifier = { fg = colors.blue },
  Statement = { fg = colors.green },
  PreProc = { fg = colors.orange },
  Type = { fg = colors.yellow },
  Special = { fg = colors.solar_red },
  SpecialComment = { link = "Comment" },
  Underlined = { fg = colors.violet },
  Ignore = { fg = colors.fgb },
  Error = { fg = colors.solar_red, bold = true },
  Todo = { link = "Error" },

  SpecialKey = { fg = colors.yellow, bold = true },
  NonText = { fg = colors.fgL, bold = true },
  StatusLine = { fg = colors.fg1, reverse = true },
  StatusLineNC = { fg = colors.fg3, reverse = true },
  Visual = { fg = colors.fg0, reverse = true },
  Directory = { link = "Identifier" },
  ErrorMsg = { fg = colors.solar_red, reverse = true },
  IncSearch = { fg = colors.orange, standout = true },
  Search = { fg = colors.yellow, reverse = true },
  MoreMsg = { link = "Identifier" },
  ModeMsg = { link = "Identifier" },
  LineNr = { fg = colors.fg2 },
  Question = { fg = colors.cyan, bold = true },
  VertSplit = { fg = colors.fg3, bg = colors.bg0 },
  Title = { fg = colors.orange, bold = true },
  VisualNOS = { bg = colors.bgd, standout = true },
  WarningMsg = { link = "Error" },
  WildMenu = { fg = colors.fg2, bg = colors.bgl },
  Folded = { fg = colors.fg0, bold = true, italic = true },
  FoldColumn = { fg = colors.fg0, bg = colors.bgd },
  DiffAdd = { fg = colors.green, bg = colors.bgd, bold = true, sp = colors.green },
  DiffChange = { fg = colors.yellow, bg = colors.bgd, bold = true, sp = colors.yellow },
  DiffDelete = { fg = colors.solar_red, bg = colors.bgd, bold = true },
  DiffText = { fg = colors.blue, bg = colors.bgd, bold = true, sp = colors.blue },
  SignColumn = { fg = colors.fg0 },
  Conceal = { link = "Identifier" },
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
  vimCommand = { link = "Type" },
  vimCmdSep = { fg = colors.blue, bold = true },
  helpExample = { fg = colors.fg1 },
  helpOption = { fg = colors.cyan },
  helpNote = { fg = colors.magenta },
  helpVim = { fg = colors.magenta },
  helpHyperTextJump = { fg = colors.blue, underline = true },
  helpHyperTextEntry = { fg = colors.green },
  vimIsCommand = { fg = colors.fg3 },
  vimSynMtchOpt = { link = "Type" },
  vimSynType = { fg = colors.cyan },
  vimHiLink = { link = "Identifier" },
  vimHiGroup = { link = "Identifier" },
  vimGroup = { fg = colors.blue, underline = true },

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
  gitcommitUnmergedFile = { fg = colors.yellow, bold = true },
  gitcommitFile = { fg = colors.fg0, bold = true },
  gitcommitDiscardedArrow = { link = "gitcommitDiscardedFile" },
  gitcommitSelectedArrow = { link = "gitcommitSelectedFile" },
  gitcommitUnmergedArrow = { link = "gitcommitUnmergedFile" },

  htmlTag = { fg = colors.fg2 },
  htmlEndTag = { fg = colors.fg2 },
  htmlTagN = { fg = colors.fg1, bold = true },
  htmlTagName = { fg = colors.blue, bold = true },
  htmlSpecialTagName = { fg = colors.blue, italic = true },
  htmlArg = { fg = colors.fg3 },
  javaScript = { link = "Type" },

  perlHereDoc = { fg = colors.fg1, bg = colors.bg0 },
  perlVarPlain = { fg = colors.yellow, bg = colors.bg0 },
  perlStatementFileDesc = { fg = colors.cyan, bg = colors.bg0 },

  texStatement = { fg = colors.cyan, bg = colors.bg0 },
  texMathZoneX = { fg = colors.yellow, bg = colors.bg0 },
  texMathMatcher = { fg = colors.yellow, bg = colors.bg0 },
  texRefLabel = { fg = colors.yellow, bg = colors.bg0 },

  cPreCondit = { link = "PreProc" },

  VarId = { link = "Identifier" },
  ConId = { link = "Type" },
  hsImport = { fg = colors.magenta },
  hsString = { fg = colors.fg3 },
  hsStructure = { fg = colors.cyan },
  hs_hlFunctionName = { link = "Function" },
  hsStatement = { fg = colors.cyan },
  hsImportLabel = { fg = colors.cyan },
  hs_OpFunctionName = { link = "Type" },
  hs_DeclareFunction = { link = "PreProc" },
  hsVarSym = { fg = colors.cyan },
  hsType = { link = "Type" },
  hsTypedef = { fg = colors.cyan },
  hsModuleName = { fg = colors.green, underline = true },
  hsModuleStartLabel = { fg = colors.magenta },
  hsImportParams = { link = "Delimiter" },
  hsDelimTypeExport = { link = "Delimiter" },
  hsModuleWhereLabel = { link = "hsModuleStartLabel" },
  hsNiceOperator = { fg = colors.cyan },
  hsniceoperator = { fg = colors.cyan },

  rustDerive = { fg = colors.orange, bg = colors.bg0 },
  rustStorage = { fg = colors.yellow, bg = colors.bg0 },
  rustReservedKeyword = { fg = colors.yellow, bg = colors.bg0 },

  pythonComment = { fg = colors.yellow, bg = colors.bg0, bold = true },

  ClangdInactiveCode = { link = "Comment" },
  ClangdClass = { fg = colors.yellow, bg = colors.bg0, italic = true },
  ClangdEnum = { fg = colors.green, bg = colors.bg0 },
  ClangdTypedef = { link = "Type" },
  ClangdTemplateParameter = { fg = colors.yellow, bg = colors.bg0, bold = true },
  ClangdFunction = { link = "Function" },
  ClangdMemberFunction = { fg = colors.blue, bg = colors.bg0, italic = true },
  ClangdStaticMemberFunction = { link = "Function" },
  ClangdEnumConstant = { fg = colors.cyan, bg = colors.bg0 },
  ClangdMacro = { fg = colors.solar_red, bg = colors.bg0 },
  ClangdNamespace = { fg = colors.green, bg = colors.bg0 },
  ClangdLocalVariable = { bg = colors.bg0 },
  ClangdVariable = { fg = colors.magenta, bg = colors.bg0 },
  ClangdParameter = { fg = colors.fg0, bg = colors.bg0 },
  ClangdField = { fg = colors.orange, bg = colors.bg0, italic = true },
  ClangdStaticField = { fg = colors.orange, bg = colors.bg0, italic = true },
  ClangdPrimitive = { link = "Type" },
  ClangdConcept = { fg = colors.solar_red, bg = colors.yellow },
  ClangdDependentName = { fg = colors.orange, bg = colors.bg0, bold = true },
  ClangdDependentType = { fg = colors.yellow, bg = colors.bg0, bold = true },

  ["@type.builtin.hlsl"] = { link = "Type" },
  ["@constructor.hlsl"] = { link = "Function" },

  ["@variable"] = { bg = colors.bg0 },
  ["@lsp.type.variable"] = { bg = colors.bg0 },
  ["@lsp.mod.mutable"] = { bg = colors.bg0, underline = true },
  ["@lsp.mod.constant"] = { fg = colors.magenta, bg = colors.bg0 },
  ["@lsp.typemod.variable.static.rust"] = { fg = colors.magenta, bg = colors.bg0 },
  ["@lsp.type.macro"] = { link = "PreProc" },
  ["@lsp.type.static"] = { fg = colors.magenta, bg = colors.bg0 },
  ["@lsp.type.enumMember"] = { fg = colors.magenta, bg = colors.bg0 },
  ["@lsp.type.property"] = { fg = colors.orange, bg = colors.bg0, italic = true },
  ["@field"] = { link = "@lsp.type.property" },
  ["@lsp.type.method"] = { fg = colors.blue, bg = colors.bg0, italic = true },
  ["@lsp.type.parameter"] = { fg = colors.fg0, bg = colors.bg0 },
  ["@lsp.type.namespace"] = { fg = colors.green, bg = colors.bg0 },
  ["@namespace"] = { fg = colors.green, bg = colors.bg0 },
  ["@lsp.type.keyword"] = { fg = colors.yellow, bg = colors.bg0 },
  ["@lsp.type.struct"] = { fg = colors.yellow, bg = colors.bg0, italic = true },
  ["@lsp.type.typeAlias.rust"] = { fg = colors.yellow, bg = colors.bg0, italic = true },
  ["@lsp.type.enum"] = { fg = colors.cyan, bg = colors.bg0 },
  ["@lsp.type.interface"] = { fg = colors.yellow, bg = colors.bg0, bold = true },
  ["@lsp.type.decorator"] = { fg = colors.solar_red, bg = colors.bg0 },
  ["@lsp.type.generic"] = { fg = colors.solar_red, bg = colors.bg0 },
  ["@lsp.type.deriveHelper"] = { fg = colors.solar_red, bg = colors.bg0 },
  ["@lsp.type.derive"] = { fg = colors.yellow, bg = colors.bg0, bold = true },

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

local terminal_colors = {
  foreground = colors.fg0,
  background = colors.bg0,
  [0] = colors.darkgray,
  [1] = colors.solar_red,
  [2] = colors.green,
  [3] = colors.yellow,
  [4] = colors.blue,
  [5] = colors.magenta,
  [6] = colors.cyan,
  [7] = colors.white,
  [8] = colors.darkgraylighter,
  [9] = colors.red,
  [10] = colors.green,
  [11] = colors.yellow,
  [12] = colors.blue,
  [13] = colors.violet,
  [14] = colors.cyan,
  [15] = colors.whitepp,
}

local function apply()
  vim.cmd("highlight clear")

  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.o.background = "dark"
  vim.g.colors_name = "nugl"

  vim.g.hs_highlight_boolean = 1
  vim.g.hs_highlight_delimiters = 1

  vim.g.terminal_color_foreground = terminal_colors.foreground
  vim.g.terminal_color_background = terminal_colors.background

  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = terminal_colors[i]
  end

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
