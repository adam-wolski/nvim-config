local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(client, bufnr)
      require("init-lsp").on_attach(client, bufnr)

      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })

      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
  dap = {
    adapter = {
      type = 'server',
      port = "${port}",
      executable = {
        command = os.getenv('CODE_LLDB_PATH'),
        args = {"--port", "${port}"},

        -- On windows you may have to uncomment this:
        -- detached = false,
      },
    },
  }
})
