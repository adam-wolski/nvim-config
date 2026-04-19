M = {}

M.lsp_progress = function()
	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		return ""
	end

	-- Find the most recently updated progress message across all clients
	local latest_msg = nil
	for _, client in ipairs(clients) do
		if client.progress then
			for progress in client.progress do
				local value = progress.value
				if type(value) == "table" and value.kind and value.kind ~= "end" then
					local msg = value.title or ""
					if value.message then
						msg = msg .. " " .. value.message
					end
					if value.percentage then
						msg = msg .. " " .. value.percentage .. "%%"
					end
					latest_msg = msg
				end
			end
		end
	end

	return latest_msg or ""
end

return M
