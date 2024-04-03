vim.cmd('packadd codecompanion.nvim')

require("codecompanion").setup({
  strategies = {
    chat = "openai",
    inline = "openai"
  },
})
