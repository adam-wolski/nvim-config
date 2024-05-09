vim.cmd('packadd nvim-dap')
vim.cmd('packadd nvim-dap-ui')

local M = {}

local dap = require "dap"

local get_exe_path = function()
  return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
end

M.get_exe_path = get_exe_path;

local rust_init_commands = function()
  -- Find out where to look for the pretty printer Python module
  local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

  local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
  local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

  local commands = {}
  local file = io.open(commands_file, 'r')
  if file then
    for line in file:lines() do
      table.insert(commands, line)
    end
    file:close()
  end
  table.insert(commands, 1, script_import)

  return commands
end

M.rust_init_commands = rust_init_commands;

local codelldb = os.getenv('CODE_LLDB_PATH')
if codelldb == nil then
  -- Fallback to binary in the path
  codelldb = "codelldb"
end

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

dap.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = 'OpenDebugAD7',
  options = {
    detached = false
  }
}

dap.adapters.rustgdb = {
  type = "executable",
  command = "rust-gdb",
  args = { "-i", "dap" }
}

dap.configurations.cpp = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",
    program = get_exe_path,
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

dap.configurations.rust = {
  {
    name = "Launch Gdb",
    type = "rustgdb",
    request = "launch",
    program = get_exe_path,
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
  {
    name = 'Launch LLDB',
    type = 'lldb',
    request = 'launch',
    program = get_exe_path,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

    initCommands = rust_init_commands,
  },
  {
    name = 'Attach LLDB',
    type = 'lldb',
    request = 'attach',
    pid = require('dap.utils').pick_process,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

    initCommands = rust_init_commands,
  },
}

dap.configurations.c = dap.configurations.cpp

dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    command = codelldb,
    args = { "--port", "${port}" },

    -- On windows you may have to uncomment this:
    -- detached = false,
  }
}

require "dapui".setup({
  layouts = {
    {
      elements = {
        {
          id = "stacks",
          size = 0.25
        },
        {
          id = "scopes",
          size = 0.5
        }
      },
      position = "right",
      size = 60
    },
    {
      elements = {
        {
          id = "scopes",
          size = 0.25
        },
        {
          id = "breakpoints",
          size = 0.25
        },
        {
          id = "stacks",
          size = 0.25
        },
        {
          id = "watches",
          size = 0.25
        }
      },
      position = "right",
      size = 60
    },
    {
      elements = {
        {
          id = "repl",
          size = 0.5
        },
      },
      position = "bottom",
      size = 20
    } },
  })

vim.fn.sign_define('DapBreakpoint', { text = '', texthl = '', linehl = '', numhl = '' })

return M;
