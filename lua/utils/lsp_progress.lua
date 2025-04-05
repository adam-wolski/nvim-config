M = {}

M.lsp_progress = function()
	if #vim.lsp.get_clients() == 0 then
		return ""
	end

	local lsp = vim.lsp.status()

	if lsp then
	  return lsp
	end
	return ""
end

return M
