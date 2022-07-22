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

  dap.adapters.codelldb = function(on_adapter)
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)

    local cmd = os.getenv('CODE_LLDB_PATH')

    local handle, pid_or_err
    local opts = {
      stdio = {nil, stdout, stderr},
      detached = true,
    }
    handle, pid_or_err = vim.loop.spawn(cmd, opts, function(code)
      stdout:close()
      stderr:close()
      handle:close()
      if code ~= 0 then
        print("codelldb exited with code", code)
      end
    end)
    assert(handle, "Error running codelldb: " .. tostring(pid_or_err))
    stdout:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        local port = chunk:match('Listening on port (%d+)')
        if port then
          vim.schedule(function()
            on_adapter({
              type = 'server',
              host = '127.0.0.1',
              port = port
            })
          end)
        else
          vim.schedule(function()
            require("dap.repl").append(chunk)
          end)
        end
      end
    end)
    stderr:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(function()
          require("dap.repl").append(chunk)
        end)
      end
    end)
  end

  dap.configurations.rust = {
    {
      name = "Launch",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
      sourceLanguages = {"rust"},
    },
  }

end

vim.g.dap_virtual_text = true

require"dapui".setup({
    icons = {
      expanded = "⯆",
      collapsed = "⯈",
    },
    mappings = {
      -- Use a table to apply multiple mappings
      expand = {"<CR>", "<2-LeftMouse>"},
      open = "o",
      remove = "d",
      edit = "e",
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil,  -- Floats will be treated as percentage of your screen.
    },
  }
)

do
  local function set_keymap(lhs, rhs)
    local keymap_opts = { noremap=true, silent=true }
    vim.api.nvim_set_keymap('n', lhs, rhs, keymap_opts)
  end

  set_keymap('<F4>',    ":lua require'dapui'.open()<CR>")
  set_keymap('<S-F4>',  ":lua require'dapui'.close()<CR>")
  set_keymap('<F5>',    ":lua require'dap'.continue()<CR>")
  set_keymap('<F10>',   ":lua require'dap'.step_over()<CR>")
  set_keymap('<F11>',   ":lua require'dap'.step_into()<CR>")
  set_keymap('<S-F11>', ":lua require'dap'.step_out()<CR>")
  set_keymap('<F9>',    ":lua require'dap'.toggle_breakpoint()<CR>")
  set_keymap('<S-F9>',  ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
  set_keymap('<F12>',   ":lua require'dap'.repl.open()<CR>")
  set_keymap('<S-F12>', ":lua require'dap'.run_last()<CR>")
end
