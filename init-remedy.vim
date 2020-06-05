lua remedybg = require('nvim_remedybg')

command! BGBreak :call v:lua.remedybg.add_breakpoint_at_current_file()
command! BGRBreak :call v:lua.remedybg.remove_breakpoint_at_current_file()
command! BGOpen :call v:lua.remedybg.open_current_file()
command! BGClose :call v:lua.remedybg.close_current_file()
command! BGStartDebug :call v:lua.remedybg.start_debugging()
command! BGStopDebug :call v:lua.remedybg.stop_debugging()
command! BGContinue :call v:lua.remedybg.continue_execution()

let g:BGBreakpointId = 4000
sign define BGBreakpoint text=* texthl=Error

nmap <silent> <F9>   :BGBreak<CR>:exe "sign place " . g:BGBreakpointId . " name=BGBreakpoint group=BGBreakpoints line=" . line('.')<CR>:let g:BGBreakpointId =  g:BGBreakpointId + 1<CR>
nmap <silent> <S-F9> :BGRBreak<CR>:sign unplace group=BGBreakpoints<CR>
nmap <silent> <F11>   :BGOpen<CR>
nmap <silent> <S-F11> :BGClose<CR>
nmap <silent> <F5>    :BGStartDebug<CR>
nmap <silent> <S-F5>  :BGStopDebug<CR>
nmap <silent> <F6>    :BGContinue<CR>
