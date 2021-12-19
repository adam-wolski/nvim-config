let g:slimv_impl = 'sbcl'
let g:slimv_unmap_tab = 1
let g:slimv_repl_split = 4 " Default to horizontal right split
let g:slimv_swank_cmd = "call jobstart('sbcl --load ~/.config/nvim/pack/lisp/opt/slimv/slime/start-swank.lisp')"

lua << EOF
local cmp = require'cmp'
cmp.setup({
  sources = cmp.config.sources({
    { name = 'omni' },
  })
})
EOF

packadd slimv


