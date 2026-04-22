vim.cmd('packadd lazygit.nvim')

vim.g.mapleader = [[ ]]
vim.g.vimsyn_embed = 'l'
vim.g.c_syntax_for_h = 1
vim.o.breakat = "),="
vim.o.grepprg = "rg --vimgrep"
vim.o.exrc = true
vim.o.path = "**"
vim.o.completeopt = "menu,popup,fuzzy"
vim.opt.breakindent = true
vim.opt.fillchars = [[fold:\]]
vim.opt.ignorecase = true
vim.opt.linebreak = true
vim.opt.mouse = "a"
vim.opt.scrolloff = 15
vim.opt.termguicolors = true

vim.cmd [[colorscheme nugl]]

-- Force load packages so sourcing init.lua script reloads modules
-- Packages are cached otherwise and require doesn't suffice
local force_load = function(module_name)
  package.loaded[module_name] = nil
  require(module_name)
end

force_load('init.cmp')
force_load('init.lsp')
force_load('init.treesitter')
force_load('init.dap')
force_load('init.telescope')
force_load('init.gitsigns')
force_load('init.map')
force_load('init.hydra')
force_load('init.ufo')
force_load('init.misc')
force_load('init.refactoring')
force_load('init.oil')
force_load('utils.uuid')
force_load('utils.lsp_progress')

if vim.g.neovide then
  force_load('init.neovide')
end

vim.o.statusline = "%{get(b:,'gitsigns_status','')} %f %{%v:lua.require('utils.lsp_progress').lsp_progress()%} %h%w%m%r%=%-14.(%l,%c%V%) %P"

function _G.fuzzy_find_files(cmdarg, _)
  local files = vim.fn.systemlist('rg --files --hidden --color=never --glob="!.git"')
  if #cmdarg == 0 then
    return files
  else
    return vim.fn.matchfuzzy(files, cmdarg)
  end
end

vim.o.findfunc = 'v:lua.fuzzy_find_files'

vim.cmd(
[[
command! ClearBuffers :%bd|e#|bd#

if has('win32')
	runtime init-windows.vim
endif

function! MyFoldText()
	let linestart = trim(getline(v:foldstart))
	let lineend = trim(getline(v:foldend))
	let indent = indent(v:foldstart)

	if linestart[0] == '(' || linestart[0] == '{' || linestart[0] == '['
		return repeat(" ", indent) . linestart[:1] . " ... " . lineend[-1:]
	else
		return repeat(" ", indent) . linestart[:-3] . "..."
	endif
endfunction

function! ScrollOff()
	let h = winheight(win_getid())
	let &scrolloff = float2nr(h * 0.35)
endfunctio

autocmd BufEnter,WinEnter,WinNew,VimResized *,*.* call ScrollOff()
autocmd User LspProgressUpdate redrawstatus
autocmd User LspRequest redrawstatus
]])


