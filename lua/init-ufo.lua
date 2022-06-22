vim.wo.foldcolumn = '1'
vim.wo.foldlevel = 99
vim.wo.foldenable = true

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

require('ufo').setup()
