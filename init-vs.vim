let mapleader = "\<Space>"

nnoremap <C-O> :call VSCodeCall("workbench.action.navigateBack")<CR>
nnoremap <C-I> :call VSCodeCall("workbench.action.navigateForward")<CR>

nmap u :call VSCodeCall("undo")<CR>
nmap <C-r> :call VSCodeCall("redo")<CR>
nmap ]e :call VSCodeCall("editor.action.marker.nextInFiles")<CR>
nmap [e :call VSCodeCall("editor.action.marker.prevInFiles")<CR>
nmap K :call VSCodeCall("editor.action.showHover")<CR>
nmap <leader>f :call VSCodeCall("workbench.action.quickOpen")<CR>
nmap <Leader>/ :nohl<CR>
