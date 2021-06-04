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
    sidebar = {
      elements = {
        -- You can change the order of elements in the sidebar
        "scopes",
        "breakpoints",
        "stacks",
        "watches",
      },
      width = 40,
      position = "left", -- Can be "left" or "right"
    },
    tray = {
      elements = {
        "repl",
      },
      height = 10,
      position = "bottom", -- Can be "bottom" or "top"
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

  set_keymap('<F5>',    ":lua require'dap'.continue()<CR>")
  set_keymap('<F10>',   ":lua require'dap'.step_over()<CR>")
  set_keymap('<F11>',   ":lua require'dap'.step_into()<CR>")
  set_keymap('<S-F11>', ":lua require'dap'.step_out()<CR>")
  set_keymap('<F9>',    ":lua require'dap'.toggle_breakpoint()<CR>")
  set_keymap('<S-F9>',  ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
  set_keymap('<F12>',   ":lua require'dap'.repl.open()<CR>")
  set_keymap('<S-F12>', ":lua require'dap'.run_last()<CR>")
end
