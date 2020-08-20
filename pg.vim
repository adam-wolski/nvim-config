runtime init-coc.vim

set tabstop=4
set shiftwidth=4
set colorcolumn=120

let g:ue_dir = $UE_PATH
let g:project_dir = getcwd() . "\\..\\..\\"
let g:uproject_file = trim(system('Get-ChildItem "../.." | Where-Object -Property Name -Match ".uproject" | foreach { $_.FullName }'))
let g:pg_dir = getcwd()
let g:ue_editor_debug_exe = g:ue_dir . "\\Engine\\Binaries\\Win64\\UE4Editor-Win64-DebugGame.exe"
let g:ue_editor_exe = g:ue_dir . "\\Engine\\Binaries\\Win64\\UE4Editor.exe"
let g:ue_insights_exe = g:ue_dir . "\\Engine\\Binaries\\Win64\\UnrealInsights.exe"
let g:ue_build = g:ue_dir . "\\Engine\\Build\\BatchFiles\\Build.bat"
let g:build_debug_args = ' -Target="WIPEditor Win64 DebugGame" -Project="' . g:uproject_file . '" -NoEngineChanges'
let g:build_debug_engine_args = ' -Target="WIPEditor Win64 DebugGame" -Project="' . g:uproject_file . '"'
let g:build_game_args = ' -Target="WIP Win64 Development" -Project="' . g:uproject_file . '" -NoEngineChanges'
let g:generate_clang_database_args = ' Win64 UE4Editor DebugGame -mode=GenerateClangDatabase -project="' . g:uproject_file . '"'

let &makeprg = g:ue_build . g:build_debug_args
let &statusline = "%{coc#status()} | " . &statusline

command! Unreal :call SetUnrealWorkspace()
command! Pg :call SetPgWorkspace()
command! CdFile :cd %:p:h

command! Run :let g:unreal_run_job_id = jobstart([g:ue_editor_debug_exe, g:uproject_file])
command! RunDx12 :let g:unreal_run_job_id = jobstart([g:ue_editor_debug_exe, g:uproject_file, '-dx12'])
command! RunInsights :call RunInsights()
command! Stop :call jobstop(g:unreal_run_job_id)
command! Push :call jobstart("git push origin develop")
command! Build :call Build(g:build_debug_args)
command! BuildEngine :call Build(g:build_debug_engine_args)
command! GenerateClangDatabase :call GenerateClangDatabase()
command! Cdb :call RunWithCdb()

nmap <silent> <A-o> :call Switch()<CR>

function! Switch()
	let ext = expand('%:e')
	let name = expand('%:t:r')
	if ext == 'h'
		execute("find " . name . ".cpp")
	else
		execute("find " . name . ".h")
	endif
endfunction

function! GenerateClangDatabase()
	execute("!" . g:ue_build . g:generate_clang_database_args)
endfunction

function! RunInsights()
	let args = g:uproject_file " -statnamedevents -trace=log,bookmark,frame,cpu,gpu,loadtime"
	let g:unreal_run_job_id = jobstart([g:ue_editor_debug_exe, args])
	let g:unreal_insights_job_id = jobstart(g:ue_insights_exe)
endfunction

function! SetUnrealWorkspace()
	execute('cd ' . g:ue_dir)
	let &path = ".,./../Private/**,./../Public/**,./../Classes/**,Engine/Source/Developer/**,Engine/Source/Editor/**,Engine/Source/Runtime/**,Engine/Source/Programs/**,Engine/Plugins/**"
endfunction

function! SetPgWorkspace()
	execute('cd ' . g:pg_dir)
	let &path = ".,Source/**,./../Private/**,./../Public/**,./../Classes/**"
endfunction

function! Build(build_args)
	let h = winheight(0)
	let termsize = h * 0.25
	let tmp = tempname()
	let g:last_build_error_file = tmp
	execute("below " . float2nr(termsize) . "split")
	execute("terminal " . g:ue_build . a:build_args . ' | Tee-Object ' . tmp)
	set ft=log
	augroup BuildGroup
		au TermClose * execute("cfile " . g:last_build_error_file)
		au TermClose * autocmd! BuildGroup
	augroup END
endfunction

function! RunWithCdb()
	let h = winheight(0)
	let termsize = h * 0.25
	execute("below " . float2nr(termsize) . "split")

	let projectsymbols = g:project_dir . "\\Binaries\\Win64\\"
	let uesymbols = g:ue_dir . "\\Engine\\Binaries\\Win64\\"

	let cdbpath = '&"C:\\Program Files (x86)\\Windows Kits\\10\\Debuggers\\x64\\cdb.exe"'
	let symbolpath = projectsymbols . ";" . uesymbols
	let cdbargs = ' -g -lines -y "' . symbolpath . '" '
	let runargs = ' ' . g:ue_editor_debug_exe . ' ' . g:uproject_file
	let terminalargs = cdbpath . cdbargs . runargs
	execute('terminal ' . terminalargs)
	set ft=log
endfunction

au BufEnter *.usf set ft=hlsl
au BufEnter *.ush set ft=hlsl
au VimEnter * call SetPgWorkspace()
au TermOpen * startinsert
