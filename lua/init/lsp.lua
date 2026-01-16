vim.cmd('packadd neodev.nvim')
vim.cmd('packadd nvim-lspconfig')
vim.cmd('packadd lsp_lines.nvim')

-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({
  library = { plugins = { "nvim-dap-ui" }, types = true },
})

local nvim_lsp = require('lspconfig')

vim.o.quickfixtextfunc = "v:lua.qf_text"

function _G.qf_text(info)
  local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
  local entries = {}
  local max_left = 0
  local max_func = 0

  for i = info.start_idx, info.end_idx do
    local item = items[i]
    local name = item.filename
    if not name or name == "" then
      name = vim.fn.bufname(item.bufnr)
    end
    if not name or name == "" then
      name = "[No Name]"
    else
      name = vim.fn.fnamemodify(name, ":t")
    end

    local line = item.lnum or 0
    local left = string.format("%s:%d", name, line)

    local text = item.text or ""
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    local func, rest = text:match("^(.-) | (.*)$")
    if not func then
      func = ""
      rest = text
    end
    func = func:gsub("^%s+", ""):gsub("%s+$", "")
    rest = rest:gsub("^%s+", ""):gsub("%s+$", "")

    if #left > max_left then
      max_left = #left
    end
    if #func > max_func then
      max_func = #func
    end

    entries[#entries + 1] = { left = left, func = func, rest = rest }
  end

  local lines = {}
  for _, entry in ipairs(entries) do
    lines[#lines + 1] = string.format(
      "%-" .. max_left .. "s | %-" .. max_func .. "s | %s",
      entry.left,
      entry.func,
      entry.rest
    )
  end

  return lines
end

local function find_first_identifier(bufnr, node)
  if not node then
    return nil
  end

  local node_type = node:type()
  if node_type == "identifier"
    or node_type == "type_identifier"
    or node_type == "field_identifier"
    or node_type == "operator_name"
    or node_type == "destructor_name"
    or node_type == "qualified_identifier"
  then
    return vim.treesitter.get_node_text(node, bufnr)
  end

  for child in node:iter_children() do
    local found = find_first_identifier(bufnr, child)
    if found then
      return found
    end
  end

  return nil
end

local function get_enclosing_type(bufnr, node)
  local type_labels = {
    struct_specifier = "struct",
    class_specifier = "class",
    union_specifier = "union",
    enum_specifier = "enum",
  }

  while node do
    local node_type = node:type()
    local label = type_labels[node_type]
    if label then
      local name_node = node:field("name")[1] or node:field("tag")[1]
      if name_node then
        return label .. " " .. vim.treesitter.get_node_text(name_node, bufnr)
      end
      if label == "struct" then
        local parent = node:parent()
        while parent do
          if parent:type() == "type_definition" then
            local decl = parent:field("declarator")[1]
            local typedef_name = find_first_identifier(bufnr, decl)
            if typedef_name then
              return label .. " " .. typedef_name
            end
            break
          end
          parent = parent:parent()
        end
      end
      return label
    end
    node = node:parent()
  end

  return nil
end

local function get_enclosing_func(bufnr, lnum, col)
  local ft = vim.bo[bufnr].filetype
  local lang = nil
  if ft == "c" or ft == 'h' then
    lang = "c"
  elseif ft == "cpp" or ft == "cxx" or ft == "cc" or ft == "hpp" then
    lang = "cpp"
  end

  if not lang then
    return nil
  end

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok or not parser then
    return nil
  end

  local tree = parser:parse()[1]
  if not tree then
    return nil
  end

  local root = tree:root()
  local row = lnum - 1
  local col0 = math.max((col or 1) - 1, 0)
  local node = root:named_descendant_for_range(row, col0, row, col0)
  local origin = node
  while node do
    local node_type = node:type()
    if node_type == "function_definition" then
      local decl = node:field("declarator")[1]
      local name = find_first_identifier(bufnr, decl)
      if name then
        return name
      end
    end
    node = node:parent()
  end

  local type_name = get_enclosing_type(bufnr, origin)
  if type_name then
    return type_name
  end

  return nil
end

function _G.lsp_references_with_context()
  local ref_clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/references" })
  local client = ref_clients[1]
  local params = vim.lsp.util.make_position_params(0, client and client.offset_encoding or nil)
  ---@type lsp.ReferenceParams
  local ref_params = vim.tbl_extend("force", params, { context = { includeDeclaration = true } })

  vim.lsp.buf_request(0, "textDocument/references", ref_params, function(err, result, ctx, _)
    if err then
      vim.notify(err.message or "LSP references error", vim.log.levels.ERROR)
      return
    end
    if not result or vim.tbl_isempty(result) then
      vim.notify("No references found", vim.log.levels.INFO)
      return
    end

    local ctx_client = vim.lsp.get_client_by_id(ctx.client_id)
    local items = vim.lsp.util.locations_to_items(result, ctx_client and ctx_client.offset_encoding or "utf-16")
    for _, item in ipairs(items) do
      local bufnr = vim.fn.bufnr(item.filename, true)
      if bufnr > 0 then
        vim.fn.bufload(bufnr)
        if vim.bo[bufnr].filetype == "c"
          or vim.bo[bufnr].filetype == "cpp"
          or vim.bo[bufnr].filetype == "cxx"
          or vim.bo[bufnr].filetype == "cc"
          or vim.bo[bufnr].filetype == "hpp"
          or vim.bo[bufnr].filetype == "h"
        then
          local func_name = get_enclosing_func(bufnr, item.lnum, item.col)
          if func_name then
            if not item.text or item.text == "" then
              local line = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1]
              item.text = line or ""
            end
            item.text = string.format("%s | %s", func_name, item.text or "")
          end
        end
      end
    end

    vim.fn.setqflist({}, " ", { title = "LSP References", items = items })
    vim.cmd("copen")
  end)
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local function map(mode, key, action, desc)
    vim.api.nvim_buf_set_keymap(bufnr, mode, key, action, { noremap=true, silent=true, desc=desc })
  end

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  map('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', "Go to declaration")
  map('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', "Go to definition")
  map('n', 'gr', '<cmd>lua lsp_references_with_context()<CR>', "Find references")
  map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', "Go to implementation")
  map('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', "Hover documentation")
  map('n', '<A-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', "Signature help")
  map('i', '<A-D>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', "Signature help")
  map('n', '<A-d>', '<cmd>lua vim.lsp.buf.type_definition()<CR>', "Type definition")
  map('n', '<A-r>', '<cmd>lua vim.lsp.buf.rename()<CR>', "Rename symbol")
  map('n', '<A-a>', '<cmd>lua vim.lsp.buf.code_action()<CR>', "Code action")
  map('v', '<A-a>', "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code action")
  map("n", '<A-f>', '<cmd>lua vim.lsp.buf.formatting()<CR>', "Format buffer")

  map('n', '<leader>lD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', "LSP: Declaration")
  map('n', '<leader>ld', '<Cmd>lua vim.lsp.buf.definition()<CR>', "LSP: Definition")
  map('n', '<leader>lr', '<cmd>lua lsp_references_with_context()<CR>', "LSP: References")
  map('n', '<leader>li', '<cmd>lua vim.lsp.buf.implementation()<CR>', "LSP: Implementation")
  map('n', '<leader>lh', '<Cmd>lua vim.lsp.buf.hover()<CR>', "LSP: Hover")
  map('n', '<leader>lk', '<cmd>lua vim.lsp.buf.signature_help()<CR>', "LSP: Signature help")
  map('n', '<leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', "LSP: Type definition")
  map('n', '<leader>lR', '<cmd>lua vim.lsp.buf.rename()<CR>', "LSP: Rename")
  map('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', "LSP: Code action")
  map('v', '<leader>la', "<cmd>lua vim.lsp.buf.code_action()<CR>", "LSP: Code action")
  map("n", '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>', "LSP: Format")
  map("n", '<leader>lm', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', "LSP: Document symbols")
  map("n", '<leader>ll', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', "LSP: Workspace symbols")

end

---@class lsp.TextDocumentClientCapabilities
---@field semanticHighlightingCapabilities? { semanticHighlighting: boolean }

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

capabilities.textDocument.semanticHighlightingCapabilities = {
  semanticHighlighting = true
}

nvim_lsp.clangd.setup {
  cmd = {'clangd', '--background-index', '--clang-tidy'},
  capabilities = capabilities,
  on_attach = on_attach,
}

if (vim.fn.has('win32') == 1) then
  nvim_lsp.powershell_es.setup {
    capabilities = capabilities,
    shell = "powershell.exe",
    bundle_path = os.getenv("PSES_BUNDLE_PATH"),
    on_attach = on_attach,
  }
end

nvim_lsp.lua_ls.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

nvim_lsp.wgsl_analyzer.setup{}

nvim_lsp.rust_analyzer.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        disabled = {
          "unresolved-proc-macro",
          "inactive-code"
        }
      }
    }
  }
}

require("lsp_lines").setup()

-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = true,
})

local M = {}
M.on_attach = on_attach;

return M
