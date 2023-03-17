vim.cmd [[packadd copilot.lua]]
vim.cmd [[packadd copilot-cmp]]

require("copilot").setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})

require("copilot_cmp").setup()
