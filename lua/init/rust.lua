local rt = require("rust-tools")

local inlays = false

local function toggle_inlays()
  if inlays then
    rt.inlay_hints.disable()
    inlays = false
  else
    rt.inlay_hints.enable()
    inlays = true
  end
end

rt.setup({
  tools = {
    inlay_hints = {
      auto = false,
    },
  },
  server = {
    on_attach = function(client, bufnr)
      require("init-lsp").on_attach(client, bufnr)

      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
      vim.keymap.set("n", "<C-h>", toggle_inlays, { buffer = bufnr })
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
