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
let &breakat="),="
let &grepprg = "rg --vimgrep"
let &statusline = "%{GitStatus()} %f %{coc#status()} %h%w%m%r%=%-14.(%l,%c%V%) %P"
let &shell = 'pwsh' 
let &shellquote= ''
let &shellpipe= '|' 
let &shellxquote= ''
let &shellcmdflag='-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
let &shellredir='| Tee-Object'
let mapleader = "\<Space>"

let g:rainbow_active = 1
let g:fzf_preview_window = '' 	" Disable preview window
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden'

colorscheme nugl

nmap <Leader>ts :SemanticHighlightToggle<CR>
nmap <Leader>s :SemanticHighlight<CR>
nmap <Leader>/ :nohl<CR>
nmap <C-p> :Files<CR>
tnoremap <Esc> <C-\><C-n>  
tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'

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
	return getbufvar(bufnr('%'), 'LastGitStatus') 
endfunction

function UpdateGitStatus()
	let filename = expand('%')
	if !len(filename)
		return ''
	endif
	let status = system("git diff --numstat " . filename)
	let matched = matchlist(status, '^\W*\(\d*\)\W*\(\d*\).*$')
	if len(matched)
		let i = matched[1]
		let d = matched[2]
		if !i && !d
			return ''
		endif
		return printf("+%d -%d", i, d)
	else
		return ''
	endif
endfunction

au BufEnter * let b:LastGitStatus = UpdateGitStatus()
au BufWritePost * let b:LastGitStatus = UpdateGitStatus()
