vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_trail_length = 0
vim.g.neovide_refresh_rate = 144
vim.g.neovide_scroll_animation_length = 0
vim.g.neovide_floating_shadow = false
vim.g.neovide_scroll_animation_far_lines = 0

local scale = function(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + delta
end

vim.api.nvim_create_user_command('ScaleUpNeovide', function() scale(0.1) end, {})
vim.api.nvim_create_user_command('ScaleDownNeovide', function() scale(-0.1) end, {})

vim.keymap.set({ 'n', 'i' }, '<C-=>', function() scale(0.1) end, { silent = true, desc = "Scale neovide up" })
vim.keymap.set({ 'n', 'i' }, '<C-->', function() scale(-0.1) end, { silent = true, desc = "Scale neovide down" })

