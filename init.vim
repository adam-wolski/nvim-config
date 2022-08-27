colorscheme nugl
set termguicolors
set exrc
set ignorecase
set hidden
set scrolloff=15
set foldtext=MyFoldText()
set fillchars=fold:\  
set foldmethod=expr
set foldlevel=10
set foldexpr=nvim_treesitter#foldexpr()
set linebreak
set breakindent
set icm=nosplit
set mouse=a
let &breakat="),="
let &grepprg = "rg --vimgrep"
let &statusline = "%{GitStatus()} %f %h%w%m%r%=%-14.(%l,%c%V%) %P"
let mapleader = "\<Space>"
let g:vimsyn_embed = 'l'

let g:neovide_refresh_rate=144
let g:neovide_cursor_animation_length=0
let g:neovide_cursor_trail_length=0

nmap <silent> <Leader>/ :nohl<CR>
tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'
nmap <silent> <leader>F :let g:neovide_fullscreen=!g:neovide_fullscreen<CR>
nmap <silent> <leader>> :call AdjustFontSize(1)<CR>
nmap <silent> <leader>< :call AdjustFontSize(-1)<CR>
nmap <silent> <leader>b <CMD>lua require('telescope.builtin').buffers()<CR>
nmap <silent> <leader>f <CMD>lua require('telescope.builtin').find_files()<CR>
nmap <silent> <leader>t <CMD>lua require('telescope.builtin').treesitter()<CR>
nmap <silent> <leader>z= <CMD>lua require('telescope.builtin').spell_suggest()<CR>
nmap <silent> <A-m> <CMD>lua require('telescope.builtin').lsp_document_symbols()<CR>
nmap <silent> <A-s> <CMD>lua require('telescope.builtin').lsp_workspace_symbols()<CR>
nmap <silent> <leader>g :LazyGit<CR>
vmap <silent> <leader>s( xi()<esc>P%
vmap <silent> <leader>s[ xi[]<esc>P%
vmap <silent> <leader>s{ xi{}<esc>P%
vmap <silent> <leader>s<lt> xi<lt>><esc>P
vmap <silent> <leader>s' xi''<esc>P
vmap <silent> <leader>s" xi""<esc>P
imap <silent> <C-R> <C-R><C-P>
nmap <silent> <leader>p "+p
vmap <silent> <leader>y "+y
nmap <silent> <leader>c gg"+yG
map Y y$

nmap <silent> <A-e> <cmd>lua vim.diagnostic.open_float()<CR>
nmap <silent> [d <cmd>lua vim.diagnostic.goto_prev()<CR>
nmap <silent> ]d <cmd>lua vim.diagnostic.goto_next()<CR>
nmap <silent> <A-q> <cmd>lua vim.diagnostic.setloclist()<CR>

command! ClearBuffers :%bd|e#|bd#

if has('win32')
	runtime init-windows.vim
endif

" NOTE: Make sure to init lsp BEFORE treesitter
" So treesitter initializes as fallback correctly
lua require'init-cmp'
lua require'init-lsp'
lua require'init-treesitter'
lua require'init-dap'
lua require'init-autopairs'
lua require'init-lint'
lua require'init-rust'
runtime init-firenvim.vim

function MyFoldText()
	let linestart = trim(getline(v:foldstart))
	let lineend = trim(getline(v:foldend))
	let indent = indent(v:foldstart)

	if linestart[0] == '(' || linestart[0] == '{' || linestart[0] == '['
		return repeat(" ", indent) . linestart[:1] . " ... " . lineend[-1:]
	else
		return repeat(" ", indent) . linestart[:-3] . "..."
	endif
endfunction

function GitStatus()
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
