M = {}

M.lsp_progress = function()
	if #vim.lsp.buf_get_clients() == 0 then
		return ""
	end

	local lsp = vim.lsp.status()

	if lsp then
		local name = lsp.name or ""
		local msg = lsp.message or ""
		local percentage = lsp.percentage or 0
		local title = lsp.title or ""
		return string.format(" %%<%s: %s %s (%s%%%%) ", name, title, msg, percentage)
	end
	return ""
end

return M
