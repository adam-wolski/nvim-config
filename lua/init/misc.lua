vim.cmd("packadd vim-venter")
vim.cmd("packadd vim-surround")

local M = {}

M.lock_window_size = function()
  vim.cmd.setlocal('winfixheight')
  vim.cmd.setlocal('winfixwidth')
end

vim.api.nvim_create_user_command('LockWindowSize', M.lock_window_size, {})

return M
