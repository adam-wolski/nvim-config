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
force_load('init.null-ls')
vim.cmd [[runtime init-firenvim.vim]]

local maps = function(mode, key, action)
  vim.keymap.set(mode, key, action, { silent = true })
end

local nmap = function (key, action)
  maps('n', key, action)
end

local imap = function (key, action)
  maps('i', key, action)
end

nmap('<A-e>', vim.diagnostic.open_float)
nmap('<A-q>', vim.diagnostic.setloclist)
nmap('<A-t>', require('sterm').toggle)
nmap('<leader>/', [[:nohl<CR>]])
nmap('<leader><', [[:call AdjustFontSize(-1)<CR>]])
nmap('<leader>>', [[:call AdjustFontSize(1)<CR>]])
nmap('<leader>F', [[:let g:neovide_fullscreen=!g:neovide_fullscreen<CR>]])
nmap('<leader>R', function() vim.cmd(string.format("source %s", os.getenv("MYVIMRC"))) end)
nmap('<leader>c', [[gg"+yG]])
nmap('<leader>g', [[:LazyGit<CR>]])
nmap('<leader>p', [["+p]])
nmap('<leader>w', [[<cmd>w<CR>]])
nmap('[d', vim.diagnostic.goto_prev)
nmap(']d', vim.diagnostic.goto_next)
nmap('<C-S-B>', [[<cmd>make<CR>]])
imap('<C-R>', [[<C-R><C-O>]])

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


