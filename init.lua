vim.g.mapleader = [[ ]]
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_trail_length = 0
vim.g.neovide_refresh_rate = 144
vim.g.vimsyn_embed = 'l'
vim.o.breakat = "),="
vim.o.grepprg = "rg --vimgrep"
vim.o.statusline = "%{get(b:,'gitsigns_status','')} %f %h%w%m%r%=%-14.(%l,%c%V%) %P"
vim.o.exrc = true
vim.opt.breakindent = true
vim.opt.fillchars = [[fold:\]]
vim.opt.foldexpr = [[nvim_treesitter#foldexpr()]]
vim.opt.foldlevel = 10
vim.opt.foldmethod = "expr"
vim.opt.foldtext = [[MyFoldText()]]
vim.opt.hidden = true
vim.opt.icm = "nosplit"
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

-- NOTE: Make sure to init lsp BEFORE treesitter
-- So treesitter initializes as fallback correctly
force_load('init.cmp')
force_load('init.lsp')
force_load('init.treesitter')
force_load('init.dap')
force_load('init.autopairs')
force_load('init.lint')
force_load('init.rust')
force_load('init.telescope')
force_load('init.gitsigns')
force_load('init.map')
force_load('init.hydra')
force_load('init.misc')
vim.cmd [[runtime init-firenvim.vim]]

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

function! AdjustFontSize(amount)
	" Split font name from FontName:hSize format and set increased size
	let current_font = &guifont
	let font_split = split(current_font, ':')
	let font = font_split[0]
	let font_size = font_split[1][1:] + a:amount
	let command = "let &guifont = \"" . font . ":h" . font_size . "\""
	:execute command
endfunction

function! ScrollOff()
	let h = winheight(win_getid())
	let &scrolloff = float2nr(h * 0.35)
endfunctio

au BufEnter,WinEnter,WinNew,VimResized *,*.* call ScrollOff()
]])


