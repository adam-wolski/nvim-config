vim.cmd('packadd neodev.nvim')
vim.cmd('packadd nvim-lspconfig')
vim.cmd('packadd lsp_lines.nvim')

-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({
  library = { plugins = { "nvim-dap-ui" }, types = true },
})

local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys 
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<A-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('i', '<A-D>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<A-d>', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<A-r>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<A-a>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('v', '<A-a>', "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", '<A-f>', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  buf_set_keymap('n', '<leader>lD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', '<leader>ld', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>li', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<leader>lh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<leader>lk', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>lR', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('v', '<leader>la', "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  buf_set_keymap("n", '<leader>lm', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
  buf_set_keymap("n", '<leader>ll', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)

end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

capabilities.textDocument.semanticHighlightingCapabilities = {
  semanticHighlighting = true
}

nvim_lsp.ltex.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

nvim_lsp.clangd.setup {
  cmd = {'clangd', '--background-index', '--clang-tidy'},
  capabilities = capabilities,
  on_attach = on_attach,
}

if (vim.fn.has('win32') == 1) then
  nvim_lsp.powershell_es.setup {
    capabilities = capabilities,
    shell = "powershell.exe",
    bundle_path = os.getenv("PSES_BUNDLE_PATH"),
    on_attach = on_attach,
  }
end

nvim_lsp.lua_ls.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

nvim_lsp.wgsl_analyzer.setup{}

nvim_lsp.rust_analyzer.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        disabled = {
          "unresolved-proc-macro",
          "inactive-code"
        }
      }
    }
  }
}


require'lspconfig'.tsserver.setup{
  capabilities = capabilities,
  on_attach = on_attach,
}

require("lsp_lines").setup()

-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = true,
})

local M = {}
M.on_attach = on_attach;

return M
