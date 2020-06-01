local function update_status()
	local output = ''
	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)
	local filename = vim.fn.expand('%')
	local git = 'git'
	local arguments = {'diff', '--numstat', filename}
	local handle = vim.loop.spawn('git', {args=arguments, stdio={stdout,stderr}},  
	vim.schedule_wrap(function()	
		local matched = vim.fn.matchlist(output, "^\\W*\\(\\d*\\)\\W*\\(\\d*\\).*$")
		if #matched == 0 then
			return
		end
		local i = matched[2]
		local d = matched[3]
		if i == 0 and d == 0 then
			vim.b.git_status = ''
			return
		end
		vim.b.git_status = vim.fn.printf("+%d -%d", i, d)
	end)
	)
	
	vim.loop.read_start(stderr, function(err, data)
		if data then
			output = output .. data
		end
	end)
end

return {run = update_status}
