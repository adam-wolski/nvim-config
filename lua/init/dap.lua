do
  local dap = require"dap"

  dap.configurations.lua = {
    {
      type = 'nlua',
      request = 'attach',
      name = "Attach to running Neovim instance",
      host = function()
        local value = vim.fn.input('Host [127.0.0.1]: ')
        if value ~= "" then
          return value
        end
        return '127.0.0.1'
      end,
      port = function()
        local val = tonumber(vim.fn.input('Port: '))
        assert(val, "Please provide a port number")
        return val
      end,
    }
  }

  dap.adapters.nlua = function(callback, config)
    callback({ type = 'server', host = config.host, port = config.port })
  end

  dap.adapters.lldb = {
    type = 'executable',
    command = 'lldb-vscode',
    name = "lldb"
  }

  dap.configurations.cpp = {
    {
      name = "Launch",
      type = "lldb",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},

      -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
      --
      --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
      --
      -- Otherwise you might get the following error:
      --
      --    Error on launch: Failed to attach to the target process
      --
      -- But you should be aware of the implications:
      -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
      runInTerminal = false,
    },
  }

  dap.configurations.c = dap.configurations.cpp

  dap.adapters.codelldb = {
    type = 'server',
    port = "${port}",
    executable = {
      -- CHANGE THIS to your path!
      command = os.getenv('CODE_LLDB_PATH'),
      args = {"--port", "${port}"},

      -- On windows you may have to uncomment this:
      -- detached = false,
    }
  }
end

require("nvim-dap-virtual-text").setup()

require"dapui".setup({})

do
  local function set_keymap(lhs, rhs)
    local keymap_opts = { noremap=true, silent=true }
    vim.api.nvim_set_keymap('n', lhs, rhs, keymap_opts)
  end

  set_keymap('<F4>',    ":lua require'dapui'.open()<CR>")
  set_keymap('<S-F4>',  ":lua require'dapui'.close()<CR>")
  set_keymap('<F5>',    ":lua require'dap'.continue()<CR>")
  set_keymap('<F10>',   ":lua require'dap'.step_over()<CR>")
  set_keymap('<S-F10>', ":lua require'dap'.run_to_cursor()<CR>")
  set_keymap('<F11>',   ":lua require'dap'.step_into()<CR>")
  set_keymap('<S-F11>', ":lua require'dap'.step_out()<CR>")
  set_keymap('<F9>',    ":lua require'dap'.toggle_breakpoint()<CR>")
  set_keymap('<S-F9>',  ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
  set_keymap('<F12>',   ":lua require'dap'.repl.open()<CR>")
  set_keymap('<S-F12>', ":lua require'dap'.run_last()<CR>")
  set_keymap('<leader>dw0', [[:lua require'dapui'.toggle({layout=0})<CR>]])
  set_keymap('<leader>dw1', [[:lua require'dapui'.toggle({layout=1})<CR>]])
  set_keymap('<leader>dw2', [[:lua require'dapui'.toggle({layout=2})<CR>]])
  set_keymap('<leader>dw3', [[:lua require'dapui'.toggle({layout=3})<CR>]])
  set_keymap('<leader>dw4', [[:lua require'dapui'.toggle({layout=4})<CR>]])
  set_keymap('<leader>dw5', [[:lua require'dapui'.toggle({layout=5})<CR>]])
  set_keymap('<leader>dw6', [[:lua require'dapui'.toggle({layout=6})<CR>]])
  set_keymap('<leader>dw7', [[:lua require'dapui'.toggle({layout=7})<CR>]])
  set_keymap('<leader>dw8', [[:lua require'dapui'.toggle({layout=8})<CR>]])
  set_keymap('<leader>dw9', [[:lua require'dapui'.toggle({layout=9})<CR>]])
  set_keymap('<leader>dwc', [[:lua require'dapui'.close()<CR>]])
  set_keymap('<leader>db', [[:lua require'dapui'.float_element("breakpoints")<CR>]])
  set_keymap('<leader>dh', [[:lua require'dapui'.float_element("hover")<CR>]])
  set_keymap('<leader>dr', [[:lua require'dapui'.float_element("repl")<CR>]])
  set_keymap('<leader>dw', [[:lua require'dapui'.float_element("watches")<CR>]])
  set_keymap('<leader>ds', [[:lua require'dapui'.float_element("stack")<CR>]])
  set_keymap('<leader>di', [[:lua require'dapui'.float_element("scopes")<CR>]])
  set_keymap('<leader>dc', [[:lua require'dapui'.float_element("console")<CR>]])
end
