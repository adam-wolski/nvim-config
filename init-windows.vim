let &shell = 'pwsh' 
let &shellquote= ''
let &shellpipe= '| Tee-Object' 
let &shellxquote= ''
let &shellcmdflag='-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
let &shellredir='| Out-File -Encoding UTF8'

let g:fzf_preview_window = ''
