vim.cmd('packadd nvim-treesitter-context')
vim.cmd('packadd rainbow-delimiters.nvim')

-- Build missing parsers on startup (no-op if all present)
require('utils.ts_parsers').ensure()

-- Languages where treesitter highlighting is disabled
local ts_highlight_disabled = { cpp = true, rust = true }

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ts_highlight_disabled[ft] then
      return
    end
    local lang = vim.treesitter.language.get_lang(ft) or ft
    pcall(vim.treesitter.start, args.buf, lang)
  end,
})

