local maps = function(mode, key, action, desc)
  vim.keymap.set(mode, key, action, { silent = true, desc = desc })
end

local nmap = function (key, action, desc)
  maps('n', key, action, desc)
end

local imap = function (key, action, desc)
  maps('i', key, action, desc)
end

local toggle_quickfix_window = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.fn.win_gettype(win) == "quickfix" then
      vim.cmd("cclose")
      return
    end
  end

  vim.cmd("cwindow")
end

nmap('<A-e>', vim.diagnostic.open_float, "Open diagnostic float")
nmap('<A-q>', vim.diagnostic.setloclist, "Set diagnostic loclist")
nmap('<leader>q', toggle_quickfix_window, "Toggle quickfix window")
nmap('<leader>/', [[:nohl<CR>]], "Clear search highlight")
nmap('<leader><', [[:call AdjustFontSize(-1)<CR>]], "Decrease font size")
nmap('<leader>>', [[:call AdjustFontSize(1)<CR>]], "Increase font size")
nmap('<leader>F', [[:let g:neovide_fullscreen=!g:neovide_fullscreen<CR>]], "Toggle fullscreen")
nmap('<leader>R', function() vim.cmd(string.format("source %s", os.getenv("MYVIMRC"))) end, "Reload config")
nmap('<leader>c', [[gg"+yG]], "Copy entire buffer to clipboard")
nmap('<leader>g', [[:LazyGit<CR>]], "Open LazyGit")
nmap('<leader>p', [["+p]], "Paste from clipboard")
nmap('<leader>w', [[<cmd>w<CR>]], "Write file")
nmap('<leader>m', [[<cmd>w<CR><cmd>MakeAsync<CR>]], "Write and make")
nmap('<C-S-B>', [[<cmd>make<CR>]], "Make")
imap('<C-R>', [[<C-R><C-O>]], "Insert register")

nmap('<A-m>', [[<CMD>lua require('telescope.builtin').lsp_document_symbols()<CR>]], "LSP document symbols")
nmap('<A-s>', [[<CMD>lua require('telescope.builtin').lsp_dynamic_workspace_symbols({fname_width = 50})<CR>]], "LSP workspace symbols")
nmap('<leader>b', [[<CMD>lua require('telescope.builtin').buffers()<CR>]], "Find buffers")
nmap('<leader>f', [[<CMD>lua require('telescope.builtin').find_files()<CR>]], "Find files")
nmap('<leader>t', [[<CMD>lua require('telescope.builtin').treesitter()<CR>]], "Treesitter symbols")
nmap('<leader>z=', [[<CMD>lua require('telescope.builtin').spell_suggest()<CR>]], "Spell suggest")
nmap('<leader>d', [[<CMD>Telescope dap<CR>]], "DAP commands")
nmap('<leader>e', [[<CMD>Telescope file_browser<CR>]], "File browser")
nmap('<leader>h', [[<CMD>Telescope help_tags<CR>]], "Help tags")

nmap('<F4>', ":lua require'dap'.terminate()<CR>", "DAP: Terminate")
nmap('<F5>', ":lua require'init.dap'.continue_improved()<CR>", "DAP: Continue")
nmap('<F6>', ":lua require'dap'.pause(0)<CR>", "DAP: Pause")
nmap('<F7>', ":lua require'dap'.run_to_cursor()<CR>", "DAP: Run to cursor")
nmap('<F8>', ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", "DAP: Set conditional breakpoint")
nmap('<F9>',    ":lua require'dap'.toggle_breakpoint()<CR>", "DAP: Toggle breakpoint")
nmap('<F10>',   ":lua require'dap'.step_over()<CR>", "DAP: Step over")
nmap('<F11>',   ":lua require'dap'.step_into()<CR>", "DAP: Step into")
nmap('<F12>',   ":lua require'dap'.step_out()<CR>", "DAP: Step out")
nmap('<leader>dp',   ":lua require'dap'.up()<CR>", "DAP: Up stack frame")
nmap('<leader>dn',   ":lua require'dap'.down()<CR>", "DAP: Down stack frame")
nmap('<leader>du', [[<CMD>lua require'init.dap_ui'.toggle()<CR>]], "DAP UI: Toggle sidebar + REPL")
nmap('<leader>dU', [[<CMD>lua require'init.dap_ui'.toggle_sidebar()<CR>]], "DAP UI: Toggle sidebar")
nmap('<leader>dl', [[<CMD>lua require'init.dap_ui'.cycle_layout()<CR>]], "DAP UI: Cycle layout")
nmap('<leader>d1', [[<CMD>lua require'init.dap_ui'.set_layout('compact')<CR>]], "DAP UI: Compact layout")
nmap('<leader>d2', [[<CMD>lua require'init.dap_ui'.set_layout('default')<CR>]], "DAP UI: Default layout")
nmap('<leader>d3', [[<CMD>lua require'init.dap_ui'.set_layout('full')<CR>]], "DAP UI: Full layout")
nmap('<leader>dr', [[<CMD>lua require'init.dap_ui'.toggle_repl()<CR>]], "DAP UI: Toggle REPL")
nmap('<leader>dh', [[<CMD>lua require'init.dap_ui'.hover()<CR>]], "DAP UI: Hover expression")
nmap('<leader>di', [[<CMD>lua require'init.dap_ui'.float('scopes')<CR>]], "DAP UI: Float scopes")
nmap('<leader>ds', [[<CMD>lua require'init.dap_ui'.float('frames')<CR>]], "DAP UI: Float frames (stack)")
nmap('<leader>dt', [[<CMD>lua require'init.dap_ui'.float('threads')<CR>]], "DAP UI: Float threads")
nmap('<leader>dS', [[<CMD>lua require'init.dap_ui'.float('sessions')<CR>]], "DAP UI: Float sessions")
nmap('<leader>db', [[<CMD>lua require'init.dap_ui'.float('breakpoints')<CR>]], "DAP UI: Float breakpoints")
nmap('<leader>dw', [[<CMD>lua require'init.dap_ui'.float('watches')<CR>]], "DAP UI: Float watches")
nmap('<leader>dwa', [[<CMD>lua require'init.dap_ui'.add_watch()<CR>]], "DAP UI: Add watch")
nmap('<leader>dwd', [[<CMD>lua require'init.dap_ui'.remove_watch()<CR>]], "DAP UI: Remove watch")
nmap('<leader>dwc', [[<CMD>lua require'init.dap_ui'.clear_watches()<CR>]], "DAP UI: Clear watches")
