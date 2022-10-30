vim.g.mapleader = [[\<Space>]]
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_trail_length = 0
vim.g.neovide_refresh_rate = 144
vim.g.vimsyn_embed = 'l'
vim.o.breakat = "),="
vim.o.grepprg = "rg --vimgrep"
vim.o.statusline = "%{GitStatus()} %f %h%w%m%r%=%-14.(%l,%c%V%) %P"
vim.opt.breakindent = true
vim.opt.exrc = true
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

-- NOTE: Make sure to init lsp BEFORE treesitter
-- So treesitter initializes as fallback correctly
require'init-cmp'
require'init-lsp'
require'init-treesitter'
require'init-dap'
require'init-autopairs'
require'init-lint'
require'init-rust'
vim.cmd [[runtime init-firenvim.vim]]

local maps = function(mode, key, action)
  vim.keymap.set(mode, key, action, { silent = true })
end

local nmap = function (key, action)
  maps('n', key, action)
end

nmap('<A-e>', [[<cmd>lua vim.diagnostic.open_float()<CR>]])
nmap('<A-m>', [[<CMD>lua require('telescope.builtin').lsp_document_symbols()<CR>]])
nmap('<A-q>', [[<cmd>lua vim.diagnostic.setloclist()<CR>]])
nmap('<A-s>', [[<CMD>lua require('telescope.builtin').lsp_workspace_symbols()<CR>]])
nmap('<A-t>', [[<cmd>lua require('sterm').toggle()<CR>]])
nmap('<Leader>/', [[:nohl<CR>]])
nmap('<leader><', [[:call AdjustFontSize(-1)<CR>]])
nmap('<leader>>', [[:call AdjustFontSize(1)<CR>]])
nmap('<leader>F', [[:let g:neovide_fullscreen=!g:neovide_fullscreen<CR>]])
nmap('<leader>b', [[<CMD>lua require('telescope.builtin').buffers()<CR>]])
nmap('<leader>c', [[gg"+yG]])
nmap('<leader>f', [[<CMD>lua require('telescope.builtin').find_files()<CR>]])
nmap('<leader>g', [[:LazyGit<CR>]])
nmap('<leader>p', [["+p]])
nmap('<leader>t', [[<CMD>lua require('telescope.builtin').treesitter()<CR>]])
nmap('<leader>z=', [[<CMD>lua require('telescope.builtin').spell_suggest()<CR>]])
nmap('[d', [[<cmd>lua vim.diagnostic.goto_prev()<CR>]])
nmap(']d', [[<cmd>lua vim.diagnostic.goto_next()<CR>]])

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

function! GitStatus()
	return getbufvar(bufnr('%'), 'git_branch') . ' ' . getbufvar(bufnr('%'), 'git_status') 
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

au BufEnter,BufWritePost * let b:git_status = '' | let b:git_branch = '' | call luaeval('require("git_status").run()')
au BufEnter,WinEnter,WinNew,VimResized *,*.* call ScrollOff()
]])


