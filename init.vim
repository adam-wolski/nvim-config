colorscheme nugl
set termguicolors
set exrc
set ignorecase
set hidden
set scrolloff=15
set foldtext=MyFoldText()
set fillchars=fold:\  
set foldmethod=syntax
set foldlevel=2
set linebreak
set breakindent
set icm=nosplit
set mouse=n
let &breakat="),="
let &grepprg = "rg --vimgrep"
let &statusline = "%{GitStatus()} %f %h%w%m%r%=%-14.(%l,%c%V%) %P"
let &guifont = "Iosevka:h16"
let mapleader = "\<Space>"
let g:vimsyn_embed = 'l'

let g:neovide_refresh_rate=140

nmap <silent> <Leader>/ :nohl<CR>
tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'
nmap <silent> <leader>F :let g:neovide_fullscreen=!g:neovide_fullscreen<CR>
nmap <silent> <leader>> :call AdjustFontSize(1)<CR>
nmap <silent> <leader>< :call AdjustFontSize(-1)<CR>
nmap <silent> <leader>b :Buffers<CR>
nmap <silent> <leader>f :Files<CR>
vmap <silent> <leader>s( xi()<esc>P%
vmap <silent> <leader>s[ xi[]<esc>P%
vmap <silent> <leader>s{ xi{}<esc>P%
vmap <silent> <leader>s<lt> xi<lt>><esc>P
vmap <silent> <leader>s' xi''<esc>P
vmap <silent> <leader>s" xi""<esc>P
imap <C-R> <C-R><C-P>

map Y y$

let g:rainbow_active = 1

let g:fzf_layout = { 'window': 'call FloatingFZF()' }
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden'
command! B :Buffers
command! F :Files
command! L :Lines

command! G :LazyGit

command! ClearBuffers :%bd|e#|bd#

if has('win32')
	runtime init-windows.vim
endif

function! FloatingFZF()
	let width = float2nr(&columns * 0.8)
	let height = float2nr(&lines * 0.6)
	let opts = { 'relative': 'editor',
		   \ 'row': (&lines - height) / 2,
		   \ 'col': (&columns - width) / 2,
		   \ 'width': width,
		   \ 'height': height }

	call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
endfunction

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

au BufEnter * let b:git_status = '' | let b:git_branch = '' | call luaeval('require("git_status").run()')
au BufWritePost * let b:git_status = '' | let b:git_branch = '' | call luaeval('require("git_status").run()')
au BufEnter,WinEnter,WinNew,VimResized *,*.* call ScrollOff()

