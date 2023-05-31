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

local codelldb_dap = {
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

local lldb_vscode_path = vim.fn.system("whereis lldb-vscode")
lldb_vscode_path = string.match(lldb_vscode_path, "lldb-vscode: ([%w%p]+)")

-- Based on rust-lldb script
local rust_host = vim.fn.system("rustc -vV")
rust_host = string.match(rust_host, "host: ([%w%p]+)")

local rust_sysroot = vim.fn.system("rustc --print sysroot")

-- script_import="command script import \"$RUSTC_SYSROOT/lib/rustlib/etc/lldb_lookup.py\""
-- commands_file="$RUSTC_SYSROOT/lib/rustlib/etc/lldb_commands"
local lldb_script_import = "command script import \"" .. rust_sysroot .. "/lib/rustlib/etc/lldb_lookup.py\""
local lldb_commands_file = rust_sysroot .. "/lib/rustlib/etc/lldb_commands"

local lldb_dap = {
  adapter = {
    type = 'executable',
    executable = {
      command = lldb_vscode_path,
      initCommands = {
        lldb_script_import,
        "source " .. lldb_commands_file,
      },
    },
  },
}

rt.setup({
  tools = {
    inlay_hints = {
      auto = false,
    },
  },
  server = {
    on_attach = function(client, bufnr)
      require("init.lsp").on_attach(client, bufnr)

      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
      vim.keymap.set("n", "<C-h>", toggle_inlays, { buffer = bufnr })
    end,
    settings = {
      ['rust-analyzer'] = {diagnostics = {disabled = {"unresolved-proc-macro"}}}
    },
  },
  dap = lldb_dap
})
