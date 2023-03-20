local nmap = function(key, action)
  vim.keymap.set('n', key, action, { silent = true })
end

nmap('<A-m>', [[<CMD>lua require('telescope.builtin').lsp_document_symbols()<CR>]])
nmap('<A-s>', [[<CMD>lua require('telescope.builtin').lsp_workspace_symbols()<CR>]])
nmap('<leader>b', [[<CMD>lua require('telescope.builtin').buffers()<CR>]])
nmap('<leader>f', [[<CMD>lua require('telescope.builtin').find_files()<CR>]])
nmap('<leader>t', [[<CMD>lua require('telescope.builtin').treesitter()<CR>]])
nmap('<leader>z=', [[<CMD>lua require('telescope.builtin').spell_suggest()<CR>]])
nmap('<leader>d', [[<CMD>Telescope dap<CR>]])
nmap('<leader>e', [[<CMD>Telescope file_browser<CR>]])
nmap('<leader>h', [[<CMD>Telescope help_tags<CR>]])

require('telescope').load_extension('dap')
require('telescope').load_extension('file_browser')
