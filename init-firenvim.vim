if exists('g:started_by_firenvim')
	let g:firenvim_config = { 
		\ 'globalSettings': {
		    \ 'alt': 'all',
		\  },
		\ 'localSettings': {
		    \ '.*': {
			\ 'cmdline': 'neovim',
			\ 'content': 'text',
			\ 'priority': 0,
			\ 'selector': 'textarea',
			\ 'takeover': 'always',
		    \ },
		\ }
	\ }

	let fc = g:firenvim_config['localSettings']
	let fc['.*'] = { 'takeover': 'never' }

	nnoremap <C-z> :call firenvim#hide_frame()<CR>

	let &guifont = ""
	au BufEnter *shadertoy.com_* set filetype=glsl
	au BufEnter *shadertoy.com_* map <leader>r :w<CR>:call firenvim#press_keys("<LT>A-CR>")<CR>

	au BufEnter *gitlab.*.com_*.txt set filetype=markdown
endif
