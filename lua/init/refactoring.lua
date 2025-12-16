vim.cmd('packadd refactoring.nvim')

vim.keymap.set("x", "<leader>re", ":Refactor extract ", {desc = "Refactor: Extract"})
vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ", {desc = "Refactor: Extract to file"})
vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ", {desc = "Refactor: Extract variable"})
vim.keymap.set({"n", "x"}, "<leader>ri", ":Refactor inline_var", {desc = "Refactor: Inline variable"})
vim.keymap.set("n", "<leader>rI", ":Refactor inline_func", {desc = "Refactor: Inline function"})
vim.keymap.set("n", "<leader>rb", ":Refactor extract_block", {desc = "Refactor: Extract block"})
vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file", {desc = "Refactor: Extract block to file"})
