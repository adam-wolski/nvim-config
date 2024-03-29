vim.cmd('packadd plenary.nvim')
vim.cmd('packadd popup.nvim')
vim.cmd('packadd telescope.nvim')
vim.cmd('packadd telescope-dap.nvim')
vim.cmd('packadd telescope-file-browser.nvim')

require('telescope').load_extension('dap')
require('telescope').load_extension('file_browser')
