set tabstop=4
set shiftwidth=4
set expandtab

inoremap ,if if () {}<Esc>3<Left>i
inoremap ,for for (;;) {}<Esc>5<Left>i
inoremap ,str typedef struct {} ;<Left>
inoremap ,inc #include ""<Left>
inoremap ,br (){}<Left><Left><Left>
