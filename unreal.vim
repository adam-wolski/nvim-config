runtime init-coc.vim

set tabstop=4
set shiftwidth=4
set colorcolumn=120

let g:project_dir = getcwd()
let g:uproject_file = trim(system('Get-ChildItem "." | Where-Object -Property Name -Match ".uproject" | foreach { $_.FullName }'))
let g:project_name = trim(system('Split-Path ' . g:uproject_file . ' -LeafBase'))
let g:engine_association = trim(system('(ConvertFrom-Json (Get-Content ' . g:uproject_file . ' -Raw)).EngineAssociation'))
let g:ue_dir = trim(system('(Get-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Epic Games\Unreal Engine\Builds")."' . g:engine_association . '"'))
if g:ue_dir == ""
	let g:ue_dir = trim(system('(Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\EpicGames\Unreal Engine\' . g:engine_association . '").InstalledDirectory'))
endif

let g:ue_editor_debug_exe = g:ue_dir . "\\Engine\\Binaries\\Win64\\UE4Editor-Win64-DebugGame.exe"
let g:ue_editor_dev_exe = g:ue_dir . "\\Engine\\Binaries\\Win64\\UE4Editor.exe"
let g:ue_insights_exe = g:ue_dir . "\\Engine\\Binaries\\Win64\\UnrealInsights.exe"
let g:ue_build = g:ue_dir . "\\Engine\\Build\\BatchFiles\\Build.bat"
let g:project_arg = ' -Project="' .g:uproject_file . '"'
let g:build_dev_args = ' -Target="' . g:project_name . 'Editor Win64 Development" -NoEngineChanges' . g:project_arg
let g:build_dev_engine_args = ' -Target="' . g:project_name . 'Editor Win64 Development"' . g:project_arg
let g:build_debug_args = ' -Target="' . g:project_name . 'Editor Win64 DebugGame" -NoEngineChanges' . g:project_arg
let g:build_debug_engine_args = ' -Target="' . g:project_name . 'Editor Win64 DebugGame"' . g:project_arg
let g:build_game_args = ' -Target="' . g:project_name . ' Win64 Development" -NoEngineChanges' . g:project_arg
let g:generate_clang_database_args = ' -Target="' . g:project_name . 'Editor Win64 DebugGame" -mode=GenerateClangDatabase' . g:project_arg
let &statusline = "%{coc#status()} | " . &statusline

let g:build_args = g:build_debug_args
let g:ue_editor_exe = g:ue_editor_debug_exe
let &makeprg = '&' . shellescape(g:ue_build) . g:build_args

let g:goyo_width = &colorcolumn + 1
let g:goyo_height = "100%"

command! Unreal :call SetUnrealWorkspace()
command! Project :call SetProjectWorkspace()
command! CdFile :cd %:p:h

command! Run :let g:unreal_run_job_id = jobstart([g:ue_editor_exe, g:uproject_file])
command! RunDx12 :let g:unreal_run_job_id = jobstart([g:ue_editor_exe, g:uproject_file, '-dx12'])
command! RunInsights :call RunInsights()
command! Stop :call jobstop(g:unreal_run_job_id)
command! Build :call Build(g:build_args)
command! GenerateClangDatabase :call GenerateClangDatabase()
command! CreateClangDatabaseLink :call CreateClangDatabaseLink()

command! SetDebugConfiguration :call SetConfiguration(g:ue_editor_debug_exe, g:build_debug_args)
command! SetDebugWithEngineConfiguration :call SetConfiguration(g:ue_editor_debug_exe, g:build_debug_engine_args)
command! SetDevelopmentConfiguration :call SetConfiguration(g:ue_editor_dev_exe, g:build_dev_args)
command! SetDevelopmentWithEngineConfiguration :call SetConfiguration(g:ue_editor_dev_exe, g:build_dev_engine_args)

command! P4Edit :!p4 edit %:p
command! P4Add :!p4 add %:p

nmap <silent> <A-o> :call Switch()<CR>
nmap <silent> <C-F5> :Run<CR>
nmap <silent> <C-S-B> :make<CR>

function! Switch()
	let ext = expand('%:e')
	let name = expand('%:t:r')
	if ext == 'h'
		execute("find " . name . ".cpp")
	else
		execute("find " . name . ".h")
	endif
endfunction

function! SetConfiguration(editor, build)
	let g:ue_editor_exe = a:editor
	let g:build_args = a:build
	let &makeprg = '&' . shellescape(g:ue_build) . g:build_args
endfunction

function! CreateClangDatabaseLink()
lua << EOF
	local target = string.format("%s/compile_commands.json", vim.g.ue_dir)
	local path = string.format("%s/compile_commands.json", vim.g.project_dir)
	vim.loop.fs_symlink(target, path, nil)
EOF
endfunction

function! GenerateClangDatabase()
	execute("!&" . shellescape(g:ue_build) . g:generate_clang_database_args)
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

function! SetProjectWorkspace()
	execute('cd ' . g:project_dir)
	let &path = ".,Source/**,./../Private/**,./../Public/**,./../Classes/**"
endfunction

function! Build(build_args)
	let h = winheight(0)
	let termsize = h * 0.25
	let tmp = tempname()
	let g:last_build_error_file = tmp
	execute("below " . float2nr(termsize) . "split")
	execute("terminal &" . shellescape(g:ue_build) . a:build_args . ' | Tee-Object ' . tmp)
	set ft=log
	augroup BuildGroup
		au TermClose * execute("cfile " . g:last_build_error_file)
		au TermClose * autocmd! BuildGroup
	augroup END
endfunction

au BufEnter *.usf set ft=hlsl
au BufEnter *.ush set ft=hlsl
au VimEnter * call SetProjectWorkspace()
au TermOpen * startinsert
