au BufWritePost *.rs :lua vim.lsp.buf.formatting()
let &makeprg = "cargo build"

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
