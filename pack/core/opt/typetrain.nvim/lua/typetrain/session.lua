-- typetrain.nvim - Session management
-- Handles file backup, ghost text, and typing tracking

local api = vim.api

---@class typetrain.Session
---@field bufnr integer
---@field filepath string
---@field backup_path string
---@field original_lines string[]
---@field config typetrain.Config
---@field ns_id integer
---@field start_time number|nil
---@field end_time number|nil
---@field keystrokes integer
---@field errors integer
---@field char_errors table<string, boolean> Track which positions had errors
---@field attached boolean
---@field finished boolean
local Session = {}
Session.__index = Session

---@param bufnr integer
---@param filepath string
---@param config typetrain.Config
---@return typetrain.Session
function Session.new(bufnr, filepath, config)
    local self = setmetatable({}, Session)
    self.bufnr = bufnr
    self.filepath = filepath
    self.backup_path = filepath .. ".typetrain.bak"
    self.original_lines = {}
    self.config = config
    self.ns_id = api.nvim_create_namespace("typetrain")
    self.ns_vlines = api.nvim_create_namespace("typetrain_vlines")
    self.vlines_extmark = nil
    self.start_time = nil
    self.end_time = nil
    self.keystrokes = 0
    self.errors = 0
    self.char_errors = {}
    self.attached = false
    self.finished = false
    return self
end

--- Start the typing session
function Session:start()
    -- Read and store original content
    self.original_lines = api.nvim_buf_get_lines(self.bufnr, 0, -1, false)

    if #self.original_lines == 0 or (#self.original_lines == 1 and self.original_lines[1] == "") then
        error("Cannot train on empty file")
    end

    -- Create backup file
    local backup_file = io.open(self.backup_path, "w")
    if not backup_file then
        error("Failed to create backup file: " .. self.backup_path)
    end
    backup_file:write(table.concat(self.original_lines, "\n"))
    backup_file:close()

    -- Clear the buffer
    api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {""})

    -- Set up ghost text (decoration provider for inline, extmarks for remaining lines)
    self:setup_ghost_text()
    self:update_errors()

    -- Attach to buffer for tracking
    self:attach()

    vim.notify("TypeTrain: Session started! Type to recreate the file. Use :TypeTrainFinish when done.", vim.log.levels.INFO)
end

--- Set up decoration provider for jitter-free ghost text rendering
function Session:setup_ghost_text()
    local self_ref = self
    api.nvim_set_decoration_provider(self.ns_id, {
        on_win = function(_, _, bufnr)
            return bufnr == self_ref.bufnr and not self_ref.finished
        end,

        on_line = function(_, _, bufnr, row)
            if bufnr ~= self_ref.bufnr or self_ref.finished then
                return
            end

            local original = self_ref.original_lines[row + 1]
            if not original then return end

            local current = api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
            local current_len = vim.fn.strchars(current)
            local original_len = vim.fn.strchars(original)

            -- Show remaining ghost text after typed content
            if current_len < original_len then
                local remaining = vim.fn.strcharpart(original, current_len)
                api.nvim_buf_set_extmark(bufnr, self_ref.ns_id, row, #current, {
                    virt_text = {{ remaining, self_ref.config.ghost_hl }},
                    virt_text_pos = "overlay",
                    ephemeral = true,
                })
            end

        end,
    })
end

--- Update error highlights and track errors (called on buffer changes)
function Session:update_errors()
    api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)

    local current_lines = api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
    local num_current = #current_lines

    local cursor = api.nvim_win_get_cursor(0)
    local cursor_row = cursor[1] - 1
    local cursor_col = cursor[2]

    for i = 1, num_current do
        local current = current_lines[i] or ""
        local original = self.original_lines[i] or ""
        local current_len = vim.fn.strchars(current)
        local row = i - 1

        local validate_up_to
        if row < cursor_row then
            validate_up_to = current_len
        elseif row == cursor_row then
            validate_up_to = vim.fn.strchars(current:sub(1, cursor_col))
        else
            validate_up_to = 0
        end

        for j = 1, validate_up_to do
            local typed_char = vim.fn.strcharpart(current, j - 1, 1)
            local expected_char = vim.fn.strcharpart(original, j - 1, 1)
            local pos_key = row .. ":" .. (j - 1)

            if typed_char ~= expected_char then
                local is_ignored = self.config.ignore_chars:find(typed_char, 1, true) ~= nil

                if not is_ignored then
                    if not self.char_errors[pos_key] then
                        self.char_errors[pos_key] = true
                        self.errors = self.errors + 1
                    end

                    local byte_start = vim.fn.byteidx(current, j - 1)
                    local byte_end = vim.fn.byteidx(current, j)
                    if byte_end == -1 then byte_end = #current end

                    api.nvim_buf_add_highlight(self.bufnr, self.ns_id, self.config.error_hl, row, byte_start, byte_end)
                end
            end
        end
    end

    -- Update virtual lines for remaining original lines (non-ephemeral, separate namespace)
    api.nvim_buf_clear_namespace(self.bufnr, self.ns_vlines, 0, -1)
    if num_current < #self.original_lines then
        local virt_lines = {}
        for i = num_current + 1, #self.original_lines do
            table.insert(virt_lines, {{ self.original_lines[i], self.config.ghost_hl }})
        end

        local last_row = num_current - 1
        if last_row < 0 then last_row = 0 end

        api.nvim_buf_set_extmark(self.bufnr, self.ns_vlines, last_row, 0, {
            virt_lines = virt_lines,
            virt_lines_above = false,
        })
    end
end

--- Attach to buffer for typing tracking
function Session:attach()
    if self.attached then return end

    self.attached = true
    api.nvim_buf_attach(self.bufnr, false, {
        on_lines = function(_, bufnr, _, first_line, last_line, new_last_line)
            if not self.attached then
                return true -- Detach
            end

            if bufnr ~= self.bufnr then
                return
            end

            -- Start timer on first input
            if not self.start_time then
                self.start_time = vim.uv.hrtime()
            end

            -- Update keystroke count (approximate)
            self.keystrokes = self.keystrokes + 1

            -- Update error highlights and check completion
            vim.schedule(function()
                if self.attached and not self.finished then
                    self:update_errors()
                    self:check_completion()
                end
            end)
        end,

        on_detach = function()
            self.attached = false
        end,
    })
end

--- Check if typing is complete
function Session:check_completion()
    local current_lines = api.nvim_buf_get_lines(self.bufnr, 0, -1, false)

    -- Check if content matches original
    if #current_lines ~= #self.original_lines then
        return false
    end

    for i, line in ipairs(current_lines) do
        if line ~= self.original_lines[i] then
            return false
        end
    end

    -- Content matches - auto finish
    self:finish()
    return true
end

--- Finish the session and show results
function Session:finish()
    if self.finished then return end
    self.finished = true

    self.end_time = vim.uv.hrtime()
    self.attached = false

    -- Calculate stats (before restoring original)
    local stats = self:calculate_stats()

    -- Disable decoration provider and clear highlights
    api.nvim_set_decoration_provider(self.ns_id, {})
    api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)
    api.nvim_buf_clear_namespace(self.bufnr, self.ns_vlines, 0, -1)

    -- Restore original content from backup
    local backup_file = io.open(self.backup_path, "r")
    if backup_file then
        local content = backup_file:read("*a")
        backup_file:close()

        local lines = vim.split(content, "\n", { plain = true })
        api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)

        os.remove(self.backup_path)
    end

    -- Show results
    self:show_results(stats)
end

--- Stop session without showing results (abort)
function Session:stop()
    self.attached = false
    self.finished = true

    -- Disable decoration provider and clear highlights
    api.nvim_set_decoration_provider(self.ns_id, {})
    api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)
    api.nvim_buf_clear_namespace(self.bufnr, self.ns_vlines, 0, -1)

    -- Restore original content from backup
    local backup_file = io.open(self.backup_path, "r")
    if backup_file then
        local content = backup_file:read("*a")
        backup_file:close()

        local lines = vim.split(content, "\n", { plain = true })
        api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)

        os.remove(self.backup_path)
    end

    vim.notify("TypeTrain: Session stopped. Original file restored.", vim.log.levels.INFO)
end

--- Calculate typing statistics
---@return table
function Session:calculate_stats()
    local elapsed_ns = (self.end_time or vim.uv.hrtime()) - (self.start_time or vim.uv.hrtime())
    local elapsed_sec = elapsed_ns / 1e9
    local elapsed_min = elapsed_sec / 60

    -- Count characters actually typed (current buffer content)
    local current_lines = api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
    local typed_chars = 0
    for _, line in ipairs(current_lines) do
        typed_chars = typed_chars + vim.fn.strchars(line)
    end
    -- Add newlines (but not for single empty line)
    if not (#current_lines == 1 and current_lines[1] == "") then
        typed_chars = typed_chars + (#current_lines - 1)
    end

    -- Count total characters in original (for progress display)
    local total_chars = 0
    for _, line in ipairs(self.original_lines) do
        total_chars = total_chars + vim.fn.strchars(line)
    end
    total_chars = total_chars + (#self.original_lines - 1)

    -- WPM calculation based on what was actually typed (standard: 5 chars = 1 word)
    local words = typed_chars / 5
    local wpm = elapsed_min > 0 and (words / elapsed_min) or 0

    -- Raw WPM (based on keystrokes)
    local raw_words = self.keystrokes / 5
    local raw_wpm = elapsed_min > 0 and (raw_words / elapsed_min) or 0

    -- Accuracy based on typed chars
    local accuracy = typed_chars > 0 and ((typed_chars - self.errors) / typed_chars * 100) or 100
    if accuracy < 0 then accuracy = 0 end

    -- Progress percentage
    local progress = total_chars > 0 and (typed_chars / total_chars * 100) or 0

    return {
        elapsed_sec = elapsed_sec,
        elapsed_min = elapsed_min,
        typed_chars = typed_chars,
        total_chars = total_chars,
        keystrokes = self.keystrokes,
        errors = self.errors,
        wpm = wpm,
        raw_wpm = raw_wpm,
        accuracy = accuracy,
        progress = progress,
        lines_typed = #current_lines,
        lines_total = #self.original_lines,
    }
end

--- Show results in a floating window
---@param stats table
function Session:show_results(stats)
    -- Exit insert mode first
    vim.cmd("stopinsert")

    local lines = {
        "TypeTrain Results",
        string.rep("=", 40),
        "",
        string.format("  WPM:          %.1f", stats.wpm),
        string.format("  Raw WPM:      %.1f", stats.raw_wpm),
        string.format("  Accuracy:     %.1f%%", stats.accuracy),
        "",
        string.format("  Time:         %.1fs (%.2f min)", stats.elapsed_sec, stats.elapsed_min),
        string.format("  Progress:     %.1f%%", stats.progress),
        string.format("  Characters:   %d / %d", stats.typed_chars, stats.total_chars),
        string.format("  Lines:        %d / %d", stats.lines_typed, stats.lines_total),
        string.format("  Keystrokes:   %d", stats.keystrokes),
        string.format("  Errors:       %d", stats.errors),
        "",
        "Press q or <Esc> to close",
    }

    -- Create floating window
    local width = 44
    local height = #lines
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    api.nvim_set_option_value("modifiable", false, { buf = buf })
    api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

    local win = api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " TypeTrain ",
        title_pos = "center",
    })

    -- Highlight title
    api.nvim_buf_add_highlight(buf, -1, self.config.stats_hl, 0, 0, -1)
    api.nvim_buf_add_highlight(buf, -1, self.config.stats_hl, 1, 0, -1)

    -- Highlight WPM line
    api.nvim_buf_add_highlight(buf, -1, "Number", 3, 16, -1)
    api.nvim_buf_add_highlight(buf, -1, "Number", 4, 16, -1)
    api.nvim_buf_add_highlight(buf, -1, "Number", 5, 16, -1)

    -- Close keymaps (both normal and insert mode just in case)
    local close = function()
        if api.nvim_win_is_valid(win) then
            api.nvim_win_close(win, true)
        end
    end

    vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
    vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
end

--- Get current status
---@return table
function Session:get_status()
    local stats = self:calculate_stats()
    return {
        active = not self.finished,
        filepath = self.filepath,
        stats = stats,
    }
end

return Session
