-- Compile tree-sitter parsers from submodules in treesitter-grammars/
-- into stdpath('data')/site/parser/ and copy queries to stdpath('data')/site/queries/
-- Skips parsers that already exist. Run :TSBuild to force rebuild all.

local parsers = {
  cmake       = {},
  commonlisp  = {},
  cpp         = {},
  c_sharp     = {},
  dockerfile  = {},
  glsl        = {},
  go          = {},
  graphql     = { queries = "queries/graphql" },
  hlsl        = {},
  html        = {},
  http        = {},
  java        = {},
  javascript  = {},
  json        = {},
  luadoc      = {},
  nu          = { queries = "queries/nu" },
  rust        = {},
  toml        = {},
  typescript  = { path = "typescript/src" },
  wgsl        = {},
  yaml        = {},
}

local M = {}

local config_dir = vim.fn.stdpath('config')
local grammar_dir = config_dir .. '/treesitter-grammars/'
local parser_dir = vim.fn.stdpath('data') .. '/site/parser/'
local query_dir = vim.fn.stdpath('data') .. '/site/queries/'

local function needs_cxx(src_path)
  return vim.uv.fs_stat(src_path .. '/scanner.cc') ~= nil
end

local function build_parser(lang, spec, force)
  local so_path = parser_dir .. lang .. '.so'
  if not force and vim.uv.fs_stat(so_path) then
    return true
  end

  local repo_dir = grammar_dir .. lang
  if not vim.uv.fs_stat(repo_dir) then
    vim.notify('TSBuild: submodule missing for ' .. lang .. ', run git submodule update --init', vim.log.levels.ERROR)
    return false
  end

  local src_path = repo_dir .. '/' .. (spec.path or 'src')

  vim.notify('TSBuild: compiling ' .. lang .. '...')
  local sources = { src_path .. '/parser.c' }
  local cc = 'cc'

  if vim.uv.fs_stat(src_path .. '/scanner.c') then
    table.insert(sources, src_path .. '/scanner.c')
  end

  local use_cxx = needs_cxx(src_path)
  if use_cxx then
    cc = 'c++'
    table.insert(sources, src_path .. '/scanner.cc')
  end

  local cmd = {
    cc, '-o', so_path, '-shared', '-fPIC', '-O2',
    '-I', src_path,
  }
  for _, s in ipairs(sources) do
    table.insert(cmd, s)
  end
  if use_cxx then
    table.insert(cmd, '-lstdc++')
  end

  local result = vim.system(cmd):wait()
  if result.code ~= 0 then
    vim.notify('TSBuild: compile failed for ' .. lang .. ': ' .. (result.stderr or ''), vim.log.levels.ERROR)
    return false
  end

  -- Copy queries from grammar submodule
  local repo_queries = repo_dir .. '/' .. (spec.queries or 'queries')
  local dest_queries = query_dir .. lang
  if vim.uv.fs_stat(repo_queries) then
    vim.fn.mkdir(dest_queries, 'p')
    for name, type in vim.fs.dir(repo_queries) do
      if type == 'file' and name:match('%.scm$') then
        vim.uv.fs_copyfile(repo_queries .. '/' .. name, dest_queries .. '/' .. name)
      end
    end
  end

  vim.notify('TSBuild: ' .. lang .. ' done')
  return true
end

function M.ensure(force)
  vim.fn.mkdir(parser_dir, 'p')
  vim.fn.mkdir(query_dir, 'p')

  local to_build = {}
  for lang, spec in pairs(parsers) do
    local so_path = parser_dir .. lang .. '.so'
    if force or not vim.uv.fs_stat(so_path) then
      table.insert(to_build, { lang = lang, spec = spec })
    end
  end

  if #to_build == 0 then
    return
  end

  table.sort(to_build, function(a, b) return a.lang < b.lang end)

  vim.notify(string.format('TSBuild: %d parser(s) to build', #to_build))
  for _, item in ipairs(to_build) do
    build_parser(item.lang, item.spec, force)
  end
  vim.notify('TSBuild: finished')
end

vim.api.nvim_create_user_command('TSBuild', function()
  M.ensure(true)
end, { desc = 'Rebuild all tree-sitter parsers from source' })

return M
