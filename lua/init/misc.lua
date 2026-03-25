vim.cmd("packadd vim-venter")
vim.cmd("packadd vim-surround")
vim.cmd("packadd nvim-autopairs")

local M = {}

M.lock_window_size = function()
  vim.cmd.setlocal('winfixheight')
  vim.cmd.setlocal('winfixwidth')
end

vim.api.nvim_create_user_command('LockWindowSize', M.lock_window_size, {})

M.scale_neovide = function(delta)
  local current = vim.g.neovide_scale_factor;
  vim.g.neovide_scale_factor = current + delta;
end

vim.api.nvim_create_user_command('ScaleUpNeovide', function() M.scale_neovide(0.1) end, {})
vim.api.nvim_create_user_command('ScaleDownNeovide', function() M.scale_neovide(-0.1) end, {})

require("nvim-autopairs").setup()

return M
