local M = {}

---@class TerminalOpts
---@field cmd? string
---@field buf? number
---@field width_ratio? number
---@field height_ratio? number
local terminal_states = {
  float = { buf = nil, win = nil },
  bottom = { buf = nil, win = nil },
  right = { buf = nil, win = nil },
  tab = { buf = nil, win = nil },
  buffer = { buf = nil, win = nil, last_buf = nil },
}

local function setup_terminal_buffer(buf, cmd)
  if buf == nil or type(buf) ~= "number" or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
    if not buf or buf == 0 then
      vim.notify("Failed to create terminal buffer", vim.log.levels.ERROR)
      return nil
    end
  end
  if vim.bo[buf].buftype ~= "terminal" then
    vim.api.nvim_buf_call(buf, function()
      vim.cmd.term(cmd or nil)
    end)
  end
  return buf
end

local function setup_close_keymap(buf, state)
  if not vim.api.nvim_buf_is_valid(buf) then
    vim.notify("Invalid buffer for keymap setup", vim.log.levels.ERROR)
    return
  end
  local close = function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    state.buf = nil
    state.win = nil
    state.last_buf = nil
  end
  vim.keymap.set("n", "q", close, { buffer = buf, silent = true })
end

function M.toggle_floating(opts)
  opts = opts or {}
  local state = terminal_states.float
  if
    state.buf
    and vim.api.nvim_buf_is_valid(state.buf)
    and vim.bo[state.buf].buftype == "terminal"
    and state.win
    and vim.api.nvim_win_is_valid(state.win)
  then
    vim.api.nvim_win_hide(state.win)
    return
  end

  local width_ratio = opts.width_ratio or 0.95
  local height_ratio = opts.height_ratio or 0.8
  local height = math.floor(vim.o.lines * height_ratio)
  local width = math.floor(vim.o.columns * width_ratio)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) or vim.bo[state.buf].buftype ~= "terminal" then
    state.buf = setup_terminal_buffer(opts.buf or state.buf, opts.cmd)
    if not state.buf then
      return
    end
  end

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  if opts.cmd and opts.cmd ~= "" then
    vim.cmd.term(opts.cmd)
  end

  setup_close_keymap(state.buf, state)
  vim.cmd.startinsert()
end

function M.toggle_bottom(opts)
  opts = opts or {}
  local state = terminal_states.bottom
  if
    state.buf
    and vim.api.nvim_buf_is_valid(state.buf)
    and vim.bo[state.buf].buftype == "terminal"
    and state.win
    and vim.api.nvim_win_is_valid(state.win)
  then
    vim.api.nvim_win_hide(state.win)
    return
  end

  local height_ratio = opts.height_ratio or 0.3
  local height = math.floor(vim.o.lines * height_ratio)

  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) or vim.bo[state.buf].buftype ~= "terminal" then
    state.buf = setup_terminal_buffer(opts.buf or state.buf, opts.cmd)
    if not state.buf then
      return
    end
  end

  vim.cmd("belowright split")
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)
  vim.api.nvim_win_set_height(state.win, height)

  if opts.cmd and opts.cmd ~= "" then
    vim.cmd.term(opts.cmd)
  end

  setup_close_keymap(state.buf, state)
  vim.cmd.startinsert()
end

function M.toggle_right(opts)
  opts = opts or {}
  local state = terminal_states.right
  if
    state.buf
    and vim.api.nvim_buf_is_valid(state.buf)
    and vim.bo[state.buf].buftype == "terminal"
    and state.win
    and vim.api.nvim_win_is_valid(state.win)
  then
    vim.api.nvim_win_hide(state.win)
    return
  end

  local width_ratio = opts.width_ratio or 0.4
  local width = math.floor(vim.o.columns * width_ratio)

  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) or vim.bo[state.buf].buftype ~= "terminal" then
    state.buf = setup_terminal_buffer(opts.buf or state.buf, opts.cmd)
    if not state.buf then
      return
    end
  end

  vim.cmd("botright vsplit")
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)
  vim.api.nvim_win_set_width(state.win, width)

  if opts.cmd and opts.cmd ~= "" then
    vim.cmd.term(opts.cmd)
  end

  setup_close_keymap(state.buf, state)
  vim.cmd.startinsert()
end

function M.toggle_tab(opts)
  opts = opts or {}
  local state = terminal_states.tab
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) and state.win and vim.api.nvim_win_is_valid(state.win) then
    local tabpage = vim.api.nvim_win_get_tabpage(state.win)
    vim.api.nvim_set_current_tabpage(tabpage)
    vim.api.nvim_win_hide(state.win)
    return
  end

  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) or vim.bo[state.buf].buftype ~= "terminal" then
    state.buf = setup_terminal_buffer(opts.buf or state.buf, opts.cmd)
    if not state.buf then
      return
    end
  end

  vim.cmd("tabnew")
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)

  if opts.cmd and opts.cmd ~= "" then
    vim.cmd.term(opts.cmd)
  end

  setup_close_keymap(state.buf, state)
  vim.cmd.startinsert()
end

function M.toggle_buffer(opts)
  opts = opts or {}
  local state = terminal_states.buffer
  local current_buf = vim.api.nvim_get_current_buf()

  if
    state.buf
    and vim.api.nvim_buf_is_valid(state.buf)
    and vim.bo[state.buf].buftype == "terminal"
    and current_buf == state.buf
  then
    if state.last_buf and vim.api.nvim_buf_is_valid(state.last_buf) then
      vim.api.nvim_set_current_buf(state.last_buf)
    else
      vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(false, true))
    end
    return
  end

  if vim.bo[current_buf].buftype ~= "terminal" then
    state.last_buf = current_buf
  end

  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) or vim.bo[state.buf].buftype ~= "terminal" then
    state.buf = setup_terminal_buffer(opts.buf or state.buf, opts.cmd)
    if not state.buf then
      return
    end
  end

  vim.api.nvim_set_current_buf(state.buf)
  state.win = vim.api.nvim_get_current_win()

  if opts.cmd and opts.cmd ~= "" then
    vim.cmd.term(opts.cmd)
  end

  setup_close_keymap(state.buf, state)
  vim.cmd.startinsert()
end

return M
