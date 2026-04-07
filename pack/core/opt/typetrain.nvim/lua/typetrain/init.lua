-- typetrain.nvim - Typing speed trainer using real project files
-- Train your typing by rewriting actual code files with full nvim support

local M = {}

---@class typetrain.Config
---@field ghost_hl string Highlight group for ghost text
---@field error_hl string Highlight group for errors (underline to preserve syntax hl)
---@field stats_hl string Highlight group for stats display
---@field ignore_chars string Characters to ignore for error counting (auto-inserted by plugins)
M.config = {
    ghost_hl = "TypeTrainGhost",
    error_hl = "TypeTrainError",
    stats_hl = "Title",
    ignore_chars = "{}()/#*",
}

-- Create highlight groups
vim.api.nvim_set_hl(0, "TypeTrainGhost", { fg = "#666666" })
vim.api.nvim_set_hl(0, "TypeTrainError", { undercurl = true, sp = "Red" })

---@type typetrain.Session|nil
M.current_session = nil

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

--- Start a typing training session on the current file
function M.start()
    -- Clear finished sessions
    if M.current_session and M.current_session.finished then
        M.current_session = nil
    end

    if M.current_session then
        vim.notify("TypeTrain: Session already active. Use :TypeTrainStop first.", vim.log.levels.WARN)
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(bufnr)

    if filepath == "" then
        vim.notify("TypeTrain: Cannot start on unnamed buffer", vim.log.levels.ERROR)
        return
    end

    local session = require("typetrain.session")
    M.current_session = session.new(bufnr, filepath, M.config)

    local ok, err = pcall(function()
        M.current_session:start()
    end)

    if not ok then
        vim.notify("TypeTrain: Failed to start session: " .. tostring(err), vim.log.levels.ERROR)
        M.current_session = nil
    end
end

--- Stop the current session and restore the original file
function M.stop()
    if not M.current_session then
        vim.notify("TypeTrain: No active session", vim.log.levels.WARN)
        return
    end

    M.current_session:stop()
    M.current_session = nil
end

--- Finish the session and show results
function M.finish()
    if not M.current_session then
        vim.notify("TypeTrain: No active session", vim.log.levels.WARN)
        return
    end

    M.current_session:finish()
    M.current_session = nil
end

--- Get current session status
---@return table|nil
function M.status()
    if not M.current_session then
        return nil
    end
    return M.current_session:get_status()
end

return M
