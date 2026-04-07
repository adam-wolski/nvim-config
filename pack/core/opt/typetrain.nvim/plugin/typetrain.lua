-- typetrain.nvim plugin loader
-- Typing speed trainer using real project files

if vim.g.loaded_typetrain then
    return
end
vim.g.loaded_typetrain = true

-- Create user commands
vim.api.nvim_create_user_command("TypeTrain", function()
    require("typetrain").start()
end, {
    desc = "Start a typing training session on the current file",
})

vim.api.nvim_create_user_command("TypeTrainStart", function()
    require("typetrain").start()
end, {
    desc = "Start a typing training session on the current file",
})

vim.api.nvim_create_user_command("TypeTrainStop", function()
    require("typetrain").stop()
end, {
    desc = "Stop the current session and restore the original file",
})

vim.api.nvim_create_user_command("TypeTrainFinish", function()
    require("typetrain").finish()
end, {
    desc = "Finish the session and show results",
})

vim.api.nvim_create_user_command("TypeTrainStatus", function()
    local status = require("typetrain").status()
    if status then
        local s = status.stats
        vim.notify(string.format(
            "TypeTrain: Active | WPM: %.1f | Accuracy: %.1f%% | Time: %.1fs",
            s.wpm, s.accuracy, s.elapsed_sec
        ), vim.log.levels.INFO)
    else
        vim.notify("TypeTrain: No active session", vim.log.levels.INFO)
    end
end, {
    desc = "Show current typing session status",
})
