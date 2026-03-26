vim.cmd("packadd vim-venter")
vim.cmd("packadd vim-surround")
vim.cmd("packadd nvim-autopairs")

local M = {}

M.lock_window_size = function()
  vim.cmd.setlocal('winfixheight')
  vim.cmd.setlocal('winfixwidth')
end

vim.api.nvim_create_user_command('LockWindowSize', M.lock_window_size, {})

M.scale_neovide = function(delta)
  local current = vim.g.neovide_scale_factor;
  vim.g.neovide_scale_factor = current + delta;
end

vim.api.nvim_create_user_command('ScaleUpNeovide', function() M.scale_neovide(0.1) end, {})
vim.api.nvim_create_user_command('ScaleDownNeovide', function() M.scale_neovide(-0.1) end, {})

require("nvim-autopairs").setup()

M.make_async = function()
  local makeprg = vim.o.makeprg
  local efm = vim.o.errorformat
  local cmd = vim.fn.expandcmd(makeprg)

  vim.notify("Building...", vim.log.levels.INFO)

  local output = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data) vim.list_extend(output, data) end,
    on_stderr = function(_, data) vim.list_extend(output, data) end,
    on_exit = function(_, exit_code, _)
      vim.schedule(function()
        if exit_code == 0 then
          local qf_title = vim.fn.getqflist({ title = 1 }).title
          if qf_title == makeprg then
            vim.fn.setqflist({}, 'r')
            vim.cmd('cclose')
          end
          vim.notify("Build succeeded", vim.log.levels.INFO)
        else
          vim.fn.setqflist({}, ' ', { title = makeprg, lines = output, efm = efm })
          vim.cmd('copen')
          vim.notify("Build failed", vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

vim.api.nvim_create_user_command('MakeAsync', M.make_async, {})

return M
