vim.cmd('packadd codecompanion.nvim')

require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "anthropic",
      slash_commands = {
        ["file"] = {
          -- Location to the slash command in CodeCompanion
          callback = "strategies.chat.slash_commands.file",
          description = "Select a file using Telescope",
          opts = {
            provider = "telescope", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
            contains_code = true,
          },
        },
      },
    },
    inline = {
      adapter = "anthropic",
    },
    cmd = {
      adapter = "anthropic",
    }
  },
  display = {
    action_palette = {
      provider = "telescope", -- default|telescope|mini_pick
    },
  },
})
