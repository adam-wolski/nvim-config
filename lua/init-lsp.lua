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
  buf_set_keymap('v', '<A-a>', ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", opts)
  buf_set_keymap("n", '<A-f>', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

nvim_lsp.ltex.setup {
  on_attach = on_attach,
  settings = {
    ltex = {
      additionalRules = {
        languageModel = '~/ngrams/',
      },
    },
  },
}

nvim_lsp.clangd.setup {
  capabilities = {
    textDocument = {
      semanticHighlightingCapabilities = {
        semanticHighlighting = true
      }
    }
  },
  on_init = require'nvim-lsp-clangd-highlight'.on_init,
  on_attach = on_attach,
}

if (vim.fn.has('win32') == 1) then
  nvim_lsp.powershell_es.setup {
    shell = "powershell.exe",
    bundle_path = os.getenv("PSES_BUNDLE_PATH"),
    on_attach = on_attach,
  }
end

local sumneko_root_path = os.getenv('LUA_LANGUAGE_SERVER')
if (sumneko_root_path) then
  local sumneko_binary = ""

  if (vim.fn.has('unix') == 1) then
    sumneko_binary = sumneko_root_path.."/bin/lua-language-server"
  else
    local system_name = "Windows" -- (Linux, macOS, or Windows)
    sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-server"
  end

  nvim_lsp.sumneko_lua.setup({
    on_attach = on_attach,
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua", '--logpath="~/.cache/nvim/lua-language-server.log"'};
    -- An example of settings for an LSP server.
    --    For more options, see nvim-lspconfig
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = vim.split(package.path, ';'),
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {'vim'},
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
          },
        },
      }
    },
  })
end

local M = {}
M.on_attach = on_attach;

return M
