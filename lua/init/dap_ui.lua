-- Simple DAP UI built on top of nvim-dap's native widgets (dap.ui.widgets).
--
-- Layout:
--   - Right sidebar with stacked Scopes / Frames / Threads / Breakpoints / Watches
--   - Bottom REPL window
--
-- Entry points:
--   require('init.dap_ui').setup()         -- call once; wires auto open/close
--   require('init.dap_ui').open()          -- open sidebar + repl
--   require('init.dap_ui').close()         -- close sidebar + repl
--   require('init.dap_ui').toggle()        -- toggle both
--   require('init.dap_ui').toggle_sidebar()
--   require('init.dap_ui').toggle_repl()
--   require('init.dap_ui').float('scopes'|'frames'|'threads'|'sessions'
--                                |'breakpoints'|'watches'|'expression')
--   require('init.dap_ui').hover()         -- native widgets.hover() on cexpr
--   require('init.dap_ui').add_watch([expr])
--   require('init.dap_ui').remove_watch()
--   require('init.dap_ui').clear_watches()
--
-- All rendering goes through nvim-dap's widget builder, so things like tree
-- expansion (`o`/`<CR>`/`a`) and action menus work out of the box. Buffers are
-- plain 'nofile' scratch buffers — no dap-ui-specific filetypes, no async
-- juggling, no session lifecycle surprises.

local api = vim.api
local widgets = require('dap.ui.widgets')
local dap_ui = require('dap.ui')
local dap_entity = require('dap.entity')

local M = {}

local SIDEBAR_WIDTH = 50
local REPL_HEIGHT = 10

-- Panel spec: widget + initial height for the horizontal split.
-- The first spec creates the vertical sidebar column; the rest stack inside it.
local LAYOUTS = {
  compact = {
    { name = 'scopes', widget_key = 'scopes', height = nil },
    { name = 'frames', widget_key = 'frames', height = 8 },
  },
  default = {
    { name = 'scopes',  widget_key = 'scopes',  height = nil },
    { name = 'watches', widget_key = 'watches', height = 8 },
    { name = 'frames',  widget_key = 'frames',  height = 8 },
  },
  full = {
    { name = 'scopes',      widget_key = 'scopes',      height = nil },
    { name = 'frames',      widget_key = 'frames',      height = 8 },
    { name = 'threads',     widget_key = 'threads',     height = 6 },
    { name = 'breakpoints', widget_key = 'breakpoints', height = 6 },
    { name = 'watches',     widget_key = 'watches',     height = 8 },
  },
}

-- Ordered list for cycling: compact → default → full → compact
local LAYOUT_ORDER = { 'compact', 'default', 'full' }

local state = {
  sidebar_views = {},  -- list of dap.ui view objects currently in the sidebar
  layout = 'default',  -- current layout name
  watches = {},        -- list of watch expression strings
  watch_results = {},  -- [expr] = { err=?, resp=? }
  watch_stale = true,  -- evaluate pending on next render
  watches_views = {},  -- [buf] = view — all open watches views
}

-- ---------------------------------------------------------------------------
-- Helpers

local function apply_sidebar_winopts(win)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].foldcolumn = '0'
  vim.wo[win].wrap = false
  vim.wo[win].statusline = ' '
  vim.wo[win].winfixwidth = true
end

-- A window counts as "dap_ui" if its buffer is one of our scratch panels, the
-- REPL, or a dap float — anywhere we'd rather *not* drop source code on top.
local function is_dap_ui_win(win)
  if not api.nvim_win_is_valid(win) then return false end
  local buf = api.nvim_win_get_buf(win)
  local ft = vim.bo[buf].filetype
  if ft == 'dap-float' or ft == 'dap-repl' then return true end
  local name = api.nvim_buf_get_name(buf)
  if vim.fn.fnamemodify(name, ':t'):match('^dap%-') then return true end
  return false
end

-- Focus the most recently used *non*-dap_ui window in the current tabpage.
-- Used before triggering frame jumps so session:_frame_set's switchbuf='uselast'
-- drops the source buffer on a real code window instead of a sibling panel.
local function focus_code_window()
  local prev = vim.fn.win_getid(vim.fn.winnr('#'))
  if prev ~= 0 and not is_dap_ui_win(prev) then
    api.nvim_set_current_win(prev)
    return true
  end
  for _, w in ipairs(api.nvim_tabpage_list_wins(0)) do
    if not is_dap_ui_win(w) then
      api.nvim_set_current_win(w)
      return true
    end
  end
  return false
end

local function set_default_buf_keymaps(buf)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = 'nofile'
  api.nvim_buf_set_keymap(buf, 'n', '<CR>',
    "<Cmd>lua require('dap.ui').trigger_actions({ mode = 'first' })<CR>", { silent = true })
  api.nvim_buf_set_keymap(buf, 'n', 'o',
    "<Cmd>lua require('dap.ui').trigger_actions()<CR>", { silent = true })
  api.nvim_buf_set_keymap(buf, 'n', 'a',
    "<Cmd>lua require('dap.ui').trigger_actions()<CR>", { silent = true })
  api.nvim_buf_set_keymap(buf, 'n', 'q',
    "<Cmd>close<CR>", { silent = true })
end

-- ---------------------------------------------------------------------------
-- Custom widgets (native dap only provides scopes/frames/threads/sessions/expression)

-- Breakpoints panel: rows are "<file>:<line> [cond=..., log=...]", Enter jumps.
M.breakpoints = {
  refresh_listener = { 'event_stopped' },
  new_buf = function()
    local buf = api.nvim_create_buf(false, true)
    set_default_buf_keymaps(buf)
    api.nvim_buf_set_name(buf, 'dap-breakpoints-' .. tostring(buf))
    return buf
  end,
  render = function(view)
    local dap_bps = require('dap.breakpoints')
    local bps_by_buf = dap_bps.get()
    local layer = view.layer()

    local items = {}
    for bufnr, bps in pairs(bps_by_buf) do
      local name = api.nvim_buf_get_name(bufnr)
      local short = vim.fn.fnamemodify(name, ':.')
      for _, bp in ipairs(bps) do
        table.insert(items, { bufnr = bufnr, line = bp.line, file = short, bp = bp })
      end
    end
    table.sort(items, function(a, b)
      if a.file == b.file then return a.line < b.line end
      return a.file < b.file
    end)

    layer.render({}, tostring, nil, 0, -1)
    if #items == 0 then
      layer.render({ 'No breakpoints set' })
      return
    end

    local context = {
      actions = {
        {
          label = 'Jump to breakpoint',
          fn = function(_, item)
            if not item then return end
            if vim.bo.bufhidden == 'wipe' then
              -- Float: close it, focus restores to the invoking window.
              view.close()
            end
            focus_code_window()
            vim.cmd('drop ' .. vim.fn.fnameescape(api.nvim_buf_get_name(item.bufnr)))
            pcall(api.nvim_win_set_cursor, 0, { item.line, 0 })
          end,
        },
        {
          label = 'Remove breakpoint',
          fn = function(_, item)
            if not item then return end
            require('dap.breakpoints').remove(item.bufnr, item.line)
            pcall(vim.fn.sign_unplace, 'dap_breakpoints', { buffer = item.bufnr, id = item.line })
            view.refresh()
          end,
        },
      },
    }

    local render_item = function(item)
      local line = string.format('%s:%d', item.file, item.line)
      local extras = {}
      if item.bp.condition then table.insert(extras, 'cond=' .. item.bp.condition) end
      if item.bp.hitCondition then table.insert(extras, 'hit=' .. item.bp.hitCondition) end
      if item.bp.logMessage then table.insert(extras, 'log=' .. item.bp.logMessage) end
      if #extras > 0 then line = line .. '  [' .. table.concat(extras, ', ') .. ']' end
      return line
    end
    layer.render(items, render_item, context)
  end,
}

-- Frames panel: mirrors native widgets.frames rendering, but focuses a real
-- code window before calling session:_frame_set so the jump doesn't land on a
-- sibling dap_ui panel.
M.frames = {
  refresh_listener = 'scopes',
  new_buf = function()
    local buf = api.nvim_create_buf(false, true)
    set_default_buf_keymaps(buf)
    api.nvim_buf_set_name(buf, 'dap-frames-' .. tostring(buf))
    return buf
  end,
  render = function(view)
    local session = require('dap').session()
    local layer = view.layer()
    if not session then
      layer.render({ 'No active session' })
      return
    end
    if not session.stopped_thread_id then
      layer.render({ 'Not stopped at any breakpoint. No frames available' })
      return
    end
    local thread = session.threads[session.stopped_thread_id]
    if not thread then
      layer.render({ string.format(
        "Stopped thread (%d) not found. Can't display frames",
        session.stopped_thread_id) })
      return
    end
    local frames = thread.frames
    require('dap.async').run(function()
      if not frames then
        local err, response = session:request('stackTrace', { threadId = thread.id })
        if err or not response then
          layer.render({ 'Stopped thread has no frames' })
          return
        end
        frames = response.stackFrames
      end
      local context = {
        actions = {
          {
            label = 'Jump to frame',
            fn = function(_, frame)
              if not session or not frame then return end
              if vim.bo.bufhidden == 'wipe' then
                view.close()
              end
              focus_code_window()
              session:_frame_set(frame)
            end,
          },
        },
      }
      layer.render(frames, dap_entity.frames.render_item, context)
    end)
  end,
}

-- Threads panel: reuses the native threads tree_spec but patches the frame
-- jump action with the same code-window focus as the frames panel above.
--
-- Note: `event_thread` alone (what nvim-dap's native widgets.threads uses)
-- isn't enough — many adapters never send thread events, and session.threads
-- is actually populated inside the session's event_stopped handler via
-- update_threads. So we also refresh on stop/continue/terminate.
M.threads = {
  refresh_listener = {
    'event_stopped',
    'event_thread',
    'event_continued',
    'event_terminated',
  },
  new_buf = function()
    local buf = api.nvim_create_buf(false, true)
    set_default_buf_keymaps(buf)
    api.nvim_buf_set_name(buf, 'dap-threads-' .. tostring(buf))
    return buf
  end,
  render = function(view)
    local layer = view.layer()
    local session = require('dap').session()
    if not session then
      layer.render({ 'No active session' })
      return
    end
    if session.dirty.threads then
      session:update_threads(function() M.threads.render(view) end)
      return
    end

    local tree = view.tree
    if not tree then
      local spec = vim.deepcopy(dap_entity.threads.tree_spec)
      local orig_compute_actions = spec.compute_actions
      spec.compute_actions = function(info)
        local actions = orig_compute_actions(info) or {}
        -- The first action on a frame row is "Jump to frame". Wrap it.
        local item = info.item
        if item and item.line then
          for _, action in ipairs(actions) do
            if action.label == 'Jump to frame' then
              local orig_fn = action.fn
              action.fn = function(layer_, frame)
                if vim.bo.bufhidden == 'wipe' then
                  view.close()
                end
                focus_code_window()
                orig_fn(layer_, frame)
              end
            end
          end
        end
        return actions
      end
      spec.extra_context = {
        view = view,
        refresh = view.refresh,
      }
      tree = dap_ui.new_tree(spec)
      view.tree = tree
    end

    local root = {
      id = 0,
      name = 'Threads',
      threads = vim.tbl_values(session.threads),
    }
    tree.render(layer, root)
  end,
}

-- Watches panel: user-managed list of expressions, re-evaluated on stop.
-- Results are cached in state.watch_results so repainting is cheap and
-- incoming evaluate callbacks don't race each other.
M.watches = {
  -- Don't use widgets.with_refresh default; we wire listeners manually in
  -- setup() so a single stop invalidates *all* watches, not per-view.
  refresh_listener = { 'event_stopped' },
  new_buf = function(view)
    local buf = api.nvim_create_buf(false, true)
    set_default_buf_keymaps(buf)
    vim.bo[buf].tagfunc = "v:lua.require'dap'._tagfunc"
    api.nvim_buf_set_keymap(buf, 'n', 'A',
      "<Cmd>lua require('init.dap_ui').add_watch()<CR>", { silent = true })
    api.nvim_buf_set_keymap(buf, 'n', 'D',
      "<Cmd>lua require('init.dap_ui').remove_watch()<CR>", { silent = true })
    api.nvim_buf_set_name(buf, 'dap-watches-' .. tostring(buf))
    state.watches_views[buf] = view
    api.nvim_buf_attach(buf, false, {
      on_detach = function(_, b) state.watches_views[b] = nil end,
    })
    return buf
  end,
  render = function(view)
    local layer = view.layer()
    layer.render({}, tostring, nil, 0, -1)

    if #state.watches == 0 then
      layer.render({ 'No watches  (A: add, D: remove)' })
      return
    end

    local session = require('dap').session()

    -- Paint whatever we have now from the cache.
    for _, expr in ipairs(state.watches) do
      layer.render({ '▸ ' .. expr })
      local cached = state.watch_results[expr]
      if not session then
        layer.render({ '  (no active session)' })
      elseif not cached then
        layer.render({ '  …' })
      elseif cached.err then
        local msg = (cached.err.message or vim.inspect(cached.err))
        layer.render({ '  error: ' .. msg })
      else
        local resp = cached.resp
        if resp.variablesReference and resp.variablesReference > 0 then
          local spec = vim.deepcopy(dap_entity.variable.tree_spec)
          spec.extra_context = { view = view }
          local tree = dap_ui.new_tree(spec)
          tree.render(layer, resp)
        else
          local value = (resp.result or ''):gsub('\n', '\\n')
          layer.render({ '  ' .. value })
        end
      end
    end

    -- If results are stale (new stop, or a watch was just added), kick off
    -- evaluates. On each completion, refresh every open watches view.
    if session and state.watch_stale then
      state.watch_stale = false
      local pending = #state.watches
      for _, expr in ipairs(state.watches) do
        session:evaluate(expr, function(err, resp)
          state.watch_results[expr] = { err = err, resp = resp }
          pending = pending - 1
          vim.schedule(function()
            -- Only refresh once all responses arrived to avoid N redraws.
            if pending > 0 then return end
            M._refresh_watches_views()
          end)
        end)
      end
    end
  end,
}

function M._refresh_watches_views()
  for buf, view in pairs(state.watches_views) do
    if api.nvim_buf_is_valid(buf) then
      pcall(view.refresh)
    else
      state.watches_views[buf] = nil
    end
  end
end

local WIDGET_BY_KEY = {
  scopes      = widgets.scopes,
  frames      = M.frames,
  threads     = M.threads,
  sessions    = widgets.sessions,
  expression  = widgets.expression,
  breakpoints = M.breakpoints,
  watches     = M.watches,
}

-- ---------------------------------------------------------------------------
-- Sidebar

local function mk_panel_win_func(wincmd)
  return function()
    vim.cmd(wincmd)
    local win = api.nvim_get_current_win()
    apply_sidebar_winopts(win)
    return win
  end
end

local function build_panel_view(widget, wincmd)
  return widgets.builder(widget)
    .new_buf(widgets.with_refresh(widget.new_buf, widget.refresh_listener or 'event_stopped'))
    .new_win(mk_panel_win_func(wincmd))
    .build()
end

function M.is_sidebar_open()
  for _, view in ipairs(state.sidebar_views) do
    if view.win and api.nvim_win_is_valid(view.win) then
      return true
    end
  end
  return false
end

function M.open_sidebar()
  if M.is_sidebar_open() then return end
  local prev_win = api.nvim_get_current_win()
  state.sidebar_views = {}

  local panels = LAYOUTS[state.layout] or LAYOUTS.default
  for i, panel in ipairs(panels) do
    local widget = WIDGET_BY_KEY[panel.widget_key]
    local wincmd
    if i == 1 then
      wincmd = string.format('botright %d vsplit', SIDEBAR_WIDTH)
    else
      wincmd = string.format('belowright %d split', panel.height or 8)
    end
    local view = build_panel_view(widget, wincmd)
    local ok, err = pcall(view.open)
    if not ok then
      vim.notify('dap_ui: failed to open ' .. panel.name .. ': ' .. tostring(err),
        vim.log.levels.WARN)
    else
      table.insert(state.sidebar_views, view)
    end
  end

  if api.nvim_win_is_valid(prev_win) then
    api.nvim_set_current_win(prev_win)
  end
end

function M.close_sidebar()
  for _, view in ipairs(state.sidebar_views) do
    pcall(view.close)
  end
  state.sidebar_views = {}
end

function M.toggle_sidebar()
  if M.is_sidebar_open() then
    M.close_sidebar()
  else
    M.open_sidebar()
  end
end

-- ---------------------------------------------------------------------------
-- Layout switching

function M.set_layout(name)
  if not LAYOUTS[name] then
    vim.notify('dap_ui: unknown layout "' .. tostring(name) .. '"', vim.log.levels.ERROR)
    return
  end
  local was_open = M.is_sidebar_open()
  if was_open then M.close_sidebar() end
  state.layout = name
  if was_open then M.open_sidebar() end
  vim.notify('dap_ui: layout → ' .. name, vim.log.levels.INFO)
end

function M.cycle_layout()
  local cur = state.layout
  local next_layout = LAYOUT_ORDER[1]
  for i, name in ipairs(LAYOUT_ORDER) do
    if name == cur and LAYOUT_ORDER[i + 1] then
      next_layout = LAYOUT_ORDER[i + 1]
      break
    end
  end
  M.set_layout(next_layout)
end

-- ---------------------------------------------------------------------------
-- REPL

function M.open_repl()
  require('dap').repl.open({ height = REPL_HEIGHT }, 'botright split')
end

function M.close_repl()
  require('dap').repl.close()
end

function M.toggle_repl()
  require('dap').repl.toggle({ height = REPL_HEIGHT }, 'botright split')
end

-- ---------------------------------------------------------------------------
-- Combined

function M.open()
  M.open_sidebar()
  M.open_repl()
end

function M.close()
  M.close_sidebar()
  M.close_repl()
end

function M.toggle()
  if M.is_sidebar_open() then
    M.close()
  else
    M.open()
  end
end

-- ---------------------------------------------------------------------------
-- Floats

function M.float(name)
  local widget = WIDGET_BY_KEY[name]
  if not widget then
    vim.notify('dap_ui: unknown widget "' .. tostring(name) .. '"', vim.log.levels.ERROR)
    return
  end
  widgets.centered_float(widget)
end

function M.hover()
  widgets.hover()
end

-- ---------------------------------------------------------------------------
-- Watch management

local function invalidate_watches()
  state.watch_stale = true
  state.watch_results = {}
  M._refresh_watches_views()
end

function M.add_watch(expr)
  if not expr or expr == '' then
    local default = vim.fn.expand('<cexpr>')
    expr = vim.fn.input({ prompt = 'Watch: ', default = default, cancelreturn = '' })
  end
  if expr == nil or expr == '' then return end
  table.insert(state.watches, expr)
  state.watch_stale = true
  state.watch_results[expr] = nil
  M._refresh_watches_views()
end

function M.remove_watch()
  if #state.watches == 0 then
    vim.notify('dap_ui: no watches to remove', vim.log.levels.INFO)
    return
  end
  vim.ui.select(state.watches, { prompt = 'Remove watch:' }, function(_, idx)
    if not idx then return end
    local expr = table.remove(state.watches, idx)
    if expr then state.watch_results[expr] = nil end
    M._refresh_watches_views()
  end)
end

function M.clear_watches()
  state.watches = {}
  state.watch_results = {}
  M._refresh_watches_views()
end

-- ---------------------------------------------------------------------------
-- Setup

function M.setup(opts)
  opts = opts or {}
  local dap = require('dap')

  -- Invalidate watch cache whenever the debugger stops or the session ends.
  dap.listeners.after.event_stopped['init.dap_ui.watches'] = invalidate_watches
  dap.listeners.after.event_terminated['init.dap_ui.watches'] = function()
    state.watch_results = {}
    M._refresh_watches_views()
  end
  dap.listeners.after.event_exited['init.dap_ui.watches'] = function()
    state.watch_results = {}
    M._refresh_watches_views()
  end

  if opts.auto_open ~= false then
    dap.listeners.after.event_initialized['init.dap_ui'] = function() M.open() end
    dap.listeners.before.event_terminated['init.dap_ui'] = function() M.close() end
    dap.listeners.before.event_exited['init.dap_ui'] = function() M.close() end
  end
end

return M
