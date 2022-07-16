autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
let &makeprg = "cargo build"

nmap <C-F5> :!cargo run<CR>

set errorformat=
\%-G,
\%-Gerror:\ aborting\ %.%#,
\%-Gerror:\ Could\ not\ compile\ %.%#,
\%Eerror:\ %m,
\%Eerror[E%n]:\ %m,
\%Wwarning:\ %m,
\%Inote:\ %m,
\%C\ %#-->\ %f:%l:%c,
\%E\ \ left:%m,%C\ right:%m\ %f:%l:%c,%Z
