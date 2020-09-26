local nmap = function(lhs, rhs)
	vim.fn.nvim_set_keymap('n', lhs, rhs, {noremap=true, silent=true});
end

nmap('<A-G>', '<cmd>lua vim.lsp.buf.declaration()<CR>')
nmap('<A-g>', '<cmd>lua vim.lsp.buf.definition()<CR>')
nmap('<A-a>', '<cmd>lua vim.lsp.buf.code_action()<CR>')
nmap('<A-d>', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
nmap('<A-f>', '<cmd>lua vim.lsp.buf.formatting()<CR>')
nmap('<A-h>', '<cmd>lua vim.lsp.buf.hover()<CR>')
nmap('<A-i>', '<cmd>lua vim.lsp.buf.implementation()<CR>')
nmap('<A-c>', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
nmap('<A-C>', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
nmap('<A-r>', '<cmd>lua vim.lsp.buf.references()<CR>')
nmap('<A-R>', '<cmd>lua vim.lsp.buf.rename()<CR>')
nmap('<A-H>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
nmap('<A-t>', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
nmap('<A-s>', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')

vim.api.nvim_command('autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()')
vim.api.nvim_command('autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()')
vim.api.nvim_command('autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()')

vim.cmd('packadd nvim-lspconfig')
require'nvim_lsp'.clangd.setup{}
