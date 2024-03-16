local function insert_uuid()
  -- Generating a UUID using an external command like 'uuidgen'
  -- This command and its availability might vary based on your system
  local handle = io.popen("uuidgen")

  if handle == nil then
    vim.notify("uuidgen not found", vim.log.levels.ERROR)
    return
  end

  local uuid = handle:read("*a")
  handle:close()

  -- Remove trailing new line character from uuid
  uuid = string.gsub(uuid, "\n", "")

  -- Remove '-' symbol to leave only the hex
  uuid = string.gsub(uuid, "-", "")

  -- Convert to all lowercase to have a standard hex format
  uuid = string.lower(uuid)

  -- Insert the UUID at the current cursor position
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local current_line = vim.api.nvim_get_current_line()
  local new_line = current_line:sub(1, col) .. uuid .. current_line:sub(col + 1)
  vim.api.nvim_set_current_line(new_line)
end

-- Register the function as a Vim command
vim.api.nvim_create_user_command('UUID', insert_uuid, {})
