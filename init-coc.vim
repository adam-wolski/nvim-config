packadd coc.nvim
packadd vim-lsp-cxx-highlight 

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
set signcolumn=auto

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

nmap <silent> <A-[> <Plug>(coc-diagnostic-prev)
nmap <silent> <A-]> <Plug>(coc-diagnostic-next)
nmap <silent> <A-d> :call <SID>show_documentation()<CR>

inoremap <silent> <expr> <C-space> coc#refresh()
nmap <silent> <A-R> <Plug>(coc-rename)
nmap <silent> <A-a> <Plug>(coc-codeaction-selected)
nmap <silent> <A-a>c <Plug>(coc-codeaction)
nmap <silent> <A-f> <Plug>(coc-format-selected)
nmap <silent> <A-g> <Plug>(coc-definition)
nmap <silent> <A-i> <Plug>(coc-implementation)
nmap <silent> <A-o> :CocCommand clangd.switchSourceHeader<CR>
nmap <silent> <A-r> <Plug>(coc-references)
nmap <silent> <A-t> <Plug>(coc-type-definition)
nmap <silent> <A-x> <Plug>(coc-fix-current)
nnoremap <silent> <A-O> :<C-u>CocList outline<CR>
nnoremap <silent> <A-j> :<C-u>CocNext<CR>
nnoremap <silent> <A-k> :<C-u>CocPrev<CR>
nnoremap <silent> <A-l> :<C-u>CocList diagnostics<CR>
nnoremap <silent> <A-p> :<C-u>CocListResume<CR>
nnoremap <silent> <A-s> :<C-u>CocList -I symbols<CR>
xmap <silent> <A-a> <Plug>(coc-codeaction-selected)
xmap <silent> <A-f> <Plug>(coc-format-selected)

xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

