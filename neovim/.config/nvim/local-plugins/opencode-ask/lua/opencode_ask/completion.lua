local state = require("opencode_ask.state")
local rules = require("opencode_ask.rules")

local M = {}

local function config()
  return state.config.completion or {}
end

local function is_enabled()
  return config().enabled ~= false
end

local function trim_extension(name)
  local trimmed = name:gsub("%.[^%.]+$", "")
  return trimmed
end

local function list_files_in_dir(dir)
  if not dir or dir == "" then
    return {}
  end
  local files = vim.fn.globpath(dir, "*", false, true)
  local items = {}
  for _, path in ipairs(files) do
    local name = vim.fn.fnamemodify(path, ":t")
    table.insert(items, trim_extension(name))
  end
  return items
end

local function list_commands()
  return list_files_in_dir(config().commands_dir)
end

local function list_rules_and_skills()
  return rules.list_rule_names()
end

local function filter_items(items, query)
  if not query or query == "" then
    return items
  end
  local lower = query:lower()
  local filtered = {}
  for _, item in ipairs(items) do
    if item:lower():find(lower, 1, true) then
      table.insert(filtered, item)
    end
  end
  return filtered
end

local function list_buffers(query)
  local items = {}
  local lower = query and query:lower() or ""
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      local name = vim.api.nvim_buf_get_name(buf)
      if name and name ~= "" then
        local display = vim.fn.fnamemodify(name, ":.")
        if lower == "" or display:lower():find(lower, 1, true) then
          table.insert(items, display)
        end
      end
    end
  end
  return items
end

local function list_files(query)
  return vim.fn.getcompletion(query or "", "file", 0)
end

local function list_context_tokens(query)
  local tokens = config().context_tokens or {}
  local cleaned = {}
  for _, token in ipairs(tokens) do
    if vim.startswith(token, "@") then
      table.insert(cleaned, token:sub(2))
    else
      table.insert(cleaned, token)
    end
  end
  return filter_items(cleaned, query)
end

local function format_file_item(item)
  if config().wrap_files then
    return "`" .. item .. "`"
  end
  return item
end

local function uniq(items)
  local out = {}
  local seen = {}
  for _, item in ipairs(items) do
    if not seen[item] then
      table.insert(out, item)
      seen[item] = true
    end
  end
  return out
end

local function with_prefix(prefix, items)
  local out = {}
  for _, item in ipairs(items) do
    table.insert(out, prefix .. item)
  end
  return out
end

local function limit_items(items)
  local max_items = config().max_items or 0
  if max_items <= 0 or #items <= max_items then
    return items
  end
  local out = {}
  for i = 1, max_items do
    out[i] = items[i]
  end
  return out
end

local function find_trigger_span()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  if col == 0 or line == "" then
    return nil
  end

  local pos = col
  if pos < 1 then
    return nil
  end

  local i = pos
  while i >= 1 do
    local ch = line:sub(i, i)
    if ch == " " or ch == "\t" then
      return nil
    end
    if ch == "@" or ch == "/" or ch == "#" then
      local start_index = i
      local j = i + 1
      while j <= #line do
        local next_ch = line:sub(j, j)
        if next_ch == " " or next_ch == "\t" then
          break
        end
        j = j + 1
      end
      local end_index = j - 1

      if start_index > 1 and line:sub(start_index - 1, start_index - 1) == "`" then
        start_index = start_index - 1
      end
      if end_index < #line and line:sub(end_index + 1, end_index + 1) == "`" then
        end_index = end_index + 1
      end

      local start_col = start_index - 1
      local end_col = end_index
      return { row = row - 1, start_col = start_col, end_col = end_col }
    end
    i = i - 1
  end
  return nil
end

local function delete_trigger_span(range)
  if not range then
    return
  end
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(0) then
      return
    end
    pcall(vim.api.nvim_buf_set_text, 0, range.row, range.start_col, range.row, range.end_col, { "" })
  end)
end

local function find_trigger(line, cursor_col)
  local i = cursor_col
  while i > 0 do
    local ch = line:sub(i, i)
    if ch == " " or ch == "\t" then
      return nil
    end
    if ch == "@" or ch == "/" or ch == "#" then
      return ch, i
    end
    i = i - 1
  end
  return nil
end

local function get_matches(trigger, query)
  local cfg = config()
  if trigger == (cfg.trigger_files or "@") then
    local items = {}
    for _, item in ipairs(list_context_tokens(query)) do
      table.insert(items, trigger .. item)
    end
    for _, item in ipairs(list_buffers(query)) do
      table.insert(items, trigger .. format_file_item(item))
    end
    for _, item in ipairs(list_files(query)) do
      table.insert(items, trigger .. format_file_item(item))
    end
    return limit_items(uniq(items))
  end

  if trigger == (cfg.trigger_commands or "/") then
    local items = filter_items(list_commands(), query)
    return with_prefix(trigger, limit_items(items))
  end

  if trigger == (cfg.trigger_rules or "#") then
    local items = filter_items(list_rules_and_skills(), query)
    return with_prefix(trigger, limit_items(items))
  end

  return {}
end

function M.maybe_complete()
  if not is_enabled() then
    return
  end
  if state.suppress_completion_once then
    state.suppress_completion_once = false
    return
  end
  if vim.fn.pumvisible() == 1 then
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local cursor_col = cursor[2] + 1
  local trigger, trigger_col = find_trigger(line, cursor_col)
  if not trigger or not trigger_col then
    return
  end

  local query = line:sub(trigger_col + 1, cursor_col)
  local matches = get_matches(trigger, query)
  if #matches == 0 then
    return
  end
  vim.fn.complete(trigger_col, matches)
end

function M.attach(buf)
  if not is_enabled() then
    return
  end
  local group = vim.api.nvim_create_augroup("opencode_ask_completion_" .. buf, { clear = true })
  vim.api.nvim_create_autocmd("TextChangedI", {
    group = group,
    buffer = buf,
    callback = function()
      if vim.api.nvim_get_current_buf() ~= buf then
        return
      end
      vim.schedule(function()
        M.maybe_complete()
      end)
    end,
  })

  vim.keymap.set("i", "<C-Space>", function()
    M.maybe_complete()
  end, { buffer = buf, nowait = true })

  vim.keymap.set("i", "<BS>", function()
    local range = find_trigger_span()
    if range then
      delete_trigger_span(range)
      state.suppress_completion_once = true
      return
    end
    vim.api.nvim_feedkeys(vim.keycode("<BS>"), "n", false)
  end, { buffer = buf, nowait = true })

  vim.keymap.set("i", "<CR>", function()
    if vim.fn.pumvisible() == 1 then
      return vim.keycode("<C-y>") .. " "
    end
    return vim.keycode("<CR>")
  end, { buffer = buf, expr = true, nowait = true })
end

return M
