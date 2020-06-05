local R = {}

local exe = "remedybg.exe"
local spawn = vim.loop.spawn

R.start = function(exe_or_rdgb)
	local a = {}
	if exe_or_rdgb then
		table.insert(a, exe_or_rdgb)
	end
	spawn(exe, {args=a}, nil)
end

R.open_session = function(filename)
	spawn(exe, {args={"open-session", filename}}, nil)
end

R.open_file = function(filename, line_number)
	local a = {"open-file", filename}
	if line_number then
		table.insert(a, line_number)
	end
	spawn(exe, {args=a}, nil)
end

R.close_file = function(filename)
	spawn(exe, {args={"close-file", filename}}, nil)
end

R.start_debugging = function()
	spawn(exe, {args={"start-debugging"}}, nil)
end

R.stop_debugging = function()
	spawn(exe, {args={"stop-debugging"}}, nil)
end

R.attach_to_process_by_id = function(process_id)
	spawn(exe, {args={"attach-to-process-by-id", process_id}}, nil)
end

R.continue_execution = function()
	spawn(exe, {args={"continue-execution"}}, nil)
end

R.add_breakpoint_at_file = function(filename, line_number)
	spawn(exe, {args={"add-breakpoint-at-file", filename, line_number}}, nil)
end

R.remove_breakpoint_at_file = function(filename, line_number)
	spawn(exe, {args={"remove-breakpoint-at-file", filename, line_number}}, nil)
end

R.add_breakpoint_at_function = function(function_name, condition_expression)
	local a = {"add-breakpoint-at-function", function_name}
	if condition_expression then
		table.insert(a, condition_expression)
	end
	spawn(exe, {args=a}, nil)
end

R.remove_breakpoint_at_function = function(function_name)
	spawn(exe, {args={"remove-breakpoint-at-function", function_name}}, nil)
end

R.open_current_file = function()
	local f = vim.fn.expand('%:p')
	local l = vim.fn.line('.')
	R.open_file(f, l)
end

R.close_current_file = function()
	local f = vim.fn.expand('%:p')
	R.close_file(f)
end

R.add_breakpoint_at_current_file = function()
	local f = vim.fn.expand('%:p')
	local l = vim.fn.line('.')
	R.add_breakpoint_at_file(f, l)
end

R.remove_breakpoint_at_current_file = function()
	local f = vim.fn.expand('%:p')
	local l = vim.fn.line('.')
	R.remove_breakpoint_at_file(f, l)
end

return R;
