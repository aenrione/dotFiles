local state = require("opencode_ask.state")
local util = require("opencode_ask.util")
local selection = require("opencode_ask.selection")
local request = require("opencode_ask.request")
local prompt = require("opencode_ask.prompt")
local completion = require("opencode_ask.completion")
local throbber = require("opencode_ask.throbber")
local highlight = require("opencode_ask.highlight")

local M = {}

local chat_hl_nsid = vim.api.nvim_create_namespace("opencode_ask_chat_hl")

local function highlight_chat_line(buf, line_nr, text)
  vim.api.nvim_buf_clear_namespace(buf, chat_hl_nsid, line_nr, line_nr + 1)
  if not text or text == "" then
    return
  end

  local ctx_tokens = state.config.completion and state.config.completion.context_tokens or { "@this", "@diff", "@diagnostics" }
  local ctx_lookup = {}
  for _, token in ipairs(ctx_tokens) do
    ctx_lookup[token] = true
  end

  for start_col, word, end_col in text:gmatch("()(%S+)()") do
    local cleaned = word:gsub("^`", ""):gsub("`$", ""):gsub("[,:;]$", "")
    local hl
    if ctx_lookup[cleaned] then
      hl = "OpenCodeChatContext"
    elseif cleaned:sub(1, 1) == "@" then
      local rest = cleaned:sub(2)
      if rest:find("/", 1, true) or rest:find("%.") or rest:find("~", 1, true) then
        hl = "OpenCodeChatPath"
      end
    elseif cleaned:sub(1, 1) == "/" then
      hl = "OpenCodeChatCommand"
    end

    if hl then
      vim.api.nvim_buf_set_extmark(buf, chat_hl_nsid, line_nr, start_col - 1, {
        end_col = end_col - 1,
        hl_group = hl,
      })
    end
  end
end

local function create_sidebar_windows()
  local prev_win = vim.api.nvim_get_current_win()
  local width, height = util.get_ui_dimensions()
  local sidebar_width = math.floor(width * (state.config.chat_sidebar_width or 0.25))
  if sidebar_width < 24 then
    sidebar_width = math.min(50, math.floor(width / 2))
  end

  local function resolve_chat_buf()
    if state.chat_state and state.chat_state.chat_buf and vim.api.nvim_buf_is_valid(state.chat_state.chat_buf) then
      return state.chat_state.chat_buf
    end
    return vim.api.nvim_create_buf(false, true)
  end

  local function resolve_input_buf()
    if state.chat_state and state.chat_state.input_buf and vim.api.nvim_buf_is_valid(state.chat_state.input_buf) then
      return state.chat_state.input_buf
    end
    return vim.api.nvim_create_buf(false, true)
  end

  if state.config.chat_use_float then
    local float_height = math.floor(height * (state.config.chat_float_height or 0.85))
    if float_height < 10 then
      float_height = math.max(6, height - 4)
    end
    local input_height = state.config.chat_input_height or 4
    local gap = 1
    local chat_height = float_height - input_height - gap
    if chat_height < 4 then
      chat_height = math.max(4, float_height - input_height)
      gap = 0
    end

    local col = width - sidebar_width - (state.config.chat_float_col_padding or 1)
    if col < 0 then
      col = 0
    end
    local row = state.config.chat_float_row
    if row == nil then
      row = math.max(0, math.floor((height - float_height) / 2))
    end

    local chat_buf = resolve_chat_buf()
    local input_buf = resolve_input_buf()
    local chat_win = vim.api.nvim_open_win(chat_buf, false, {
      relative = "editor",
      width = sidebar_width,
      height = chat_height,
      row = row,
      col = col,
      style = "minimal",
      border = state.config.chat_border or "single",
    })
    local input_win = vim.api.nvim_open_win(input_buf, true, {
      relative = "editor",
      width = sidebar_width,
      height = input_height,
      row = row + chat_height + gap,
      col = col,
      style = "minimal",
      border = state.config.chat_border or "single",
    })

    return {
      prev_win = prev_win,
      chat_win = chat_win,
      chat_buf = chat_buf,
      input_win = input_win,
      input_buf = input_buf,
      height = height,
    }
  end

  vim.cmd("botright vsplit")
  local chat_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(chat_win, sidebar_width)

  local chat_buf = resolve_chat_buf()
  vim.api.nvim_win_set_buf(chat_win, chat_buf)

  vim.cmd("split")
  local input_win = vim.api.nvim_get_current_win()
  local input_buf = resolve_input_buf()
  vim.api.nvim_win_set_buf(input_win, input_buf)
  vim.api.nvim_win_set_height(input_win, state.config.chat_input_height or 4)

  vim.api.nvim_set_current_win(input_win)

  return {
    prev_win = prev_win,
    chat_win = chat_win,
    chat_buf = chat_buf,
    input_win = input_win,
    input_buf = input_buf,
    height = height,
  }
end

local function append_chat_lines(buf, lines)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local start_line = vim.api.nvim_buf_line_count(buf)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  vim.bo[buf].modifiable = false
  for i, line in ipairs(lines) do
    highlight.apply_line(buf, start_line + i - 1, line)
  end
end

local function normalize_lines(lines)
  local normalized = {}
  for _, line in ipairs(lines) do
    local chunks = vim.split(line, "\n", { plain = true })
    for _, chunk in ipairs(chunks) do
      table.insert(normalized, chunk)
    end
  end
  return normalized
end

local function highlight_buffer(buf)
  highlight.apply_buffer(buf)
end

local function replace_chat_line(buf, start_line, new_lines)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, start_line, start_line + 1, false, new_lines)
  vim.bo[buf].modifiable = false
  for i, line in ipairs(new_lines) do
    highlight.apply_line(buf, start_line + i - 1, line)
  end
end

local function setup_chat_buffers(chat_buf, input_buf)
  if vim.api.nvim_buf_get_name(chat_buf) == "" then
    vim.api.nvim_buf_set_name(chat_buf, util.unique_buf_name("opencode-ask-chat"))
  end
  if vim.api.nvim_buf_get_name(input_buf) == "" then
    vim.api.nvim_buf_set_name(input_buf, util.unique_buf_name("opencode-ask-chat-input"))
  end
  vim.bo[chat_buf].buftype = "nofile"
  vim.bo[chat_buf].bufhidden = "hide"
  vim.bo[chat_buf].swapfile = false
  if state.config.chat_render_markdown then
    vim.bo[chat_buf].filetype = "markdown"
    vim.bo[chat_buf].syntax = "markdown"
    pcall(function()
      if vim.treesitter and vim.treesitter.start then
        vim.treesitter.start(chat_buf, "markdown")
      end
    end)
  else
    vim.bo[chat_buf].filetype = "opencode_ask_chat"
  end
  vim.bo[chat_buf].modifiable = false
  vim.bo[input_buf].buftype = "acwrite"
  vim.bo[input_buf].bufhidden = "wipe"
  vim.bo[input_buf].swapfile = false
  vim.bo[input_buf].filetype = "opencode_ask_prompt"
end

local function setup_chat_highlights()
  if state.chat_highlights_set then
    return
  end
  state.chat_highlights_set = true
  vim.api.nvim_set_hl(0, "OpenCodeChatTitle", { link = "FloatTitle" })
  vim.api.nvim_set_hl(0, "OpenCodeChatTitleAccent", { link = "FloatBorder" })
  vim.api.nvim_set_hl(0, "OpenCodeChatSeparator", { link = "WinSeparator" })
  vim.api.nvim_set_hl(0, "OpenCodeChatNormal", { link = "NormalFloat" })
end


local function start_chat_spinner(buf, line_nr)
  return throbber.start({
    interval = 120,
    on_tick = function(frame)
      replace_chat_line(buf, line_nr, { "Assistant: " .. frame })
    end,
  })
end

local function build_selection_hint(selection_ctx)
  if not selection_ctx then
    return ""
  end
  local file = vim.api.nvim_buf_get_name(selection_ctx.buf)
  if file == "" then
    return "@this "
  end
  local start_line = (selection_ctx.start_row or 0) + 1
  local end_line = (selection_ctx.end_row or selection_ctx.start_row or 0) + 1
  local range = start_line == end_line and tostring(start_line) or (tostring(start_line) .. "-" .. tostring(end_line))
  local hint = string.format("@this `%s:%s` ", file, range)
  if hint:sub(-1) ~= " " then
    hint = hint .. " "
  end
  return hint
end

local function setup_chat_window_options(chat_win)
  vim.wo[chat_win].wrap = true
  vim.wo[chat_win].number = false
  vim.wo[chat_win].relativenumber = false
  vim.wo[chat_win].statusline = " "
  if state.config.chat_winbar ~= false then
    vim.wo[chat_win].winbar = "%#OpenCodeChatTitle# OpenCode Chat %#OpenCodeChatTitleAccent#│%*"
  end
  vim.wo[chat_win].winfixwidth = true
  vim.wo[chat_win].winhighlight = "Normal:OpenCodeChatNormal,WinSeparator:OpenCodeChatSeparator,FloatBorder:OpenCodeChatSeparator"
  if state.config.chat_render_markdown then
    vim.wo[chat_win].conceallevel = state.config.chat_conceallevel or 2
    vim.wo[chat_win].concealcursor = state.config.chat_concealcursor or "nc"
  end
end

local function setup_input_window_options(input_win)
  vim.wo[input_win].wrap = true
  vim.wo[input_win].number = false
  vim.wo[input_win].relativenumber = false
  vim.wo[input_win].statusline = " "
  if state.config.chat_winbar ~= false then
    vim.wo[input_win].winbar = "%#OpenCodeChatTitle# OpenCode Input %#OpenCodeChatTitleAccent#│%*"
  end
  vim.wo[input_win].winfixwidth = true
  vim.wo[input_win].winfixheight = true
  vim.wo[input_win].winhighlight = "Normal:OpenCodeChatNormal,WinSeparator:OpenCodeChatSeparator,FloatBorder:OpenCodeChatSeparator"
end

local function handle_chat_submit(input_buf)
  local session = vim.b[input_buf].opencode_chat
  if not session or not vim.api.nvim_buf_is_valid(session.chat_buf) then
    util.notify("OpenCodeAsk: chat session not found", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(input_buf, 0, -1, false)
  local question = vim.trim(table.concat(lines, "\n"))
  if question == "" then
    return
  end

  vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, { "" })
  vim.bo[input_buf].modified = false

  local question_lines = vim.split(question, "\n", { plain = true })
  if #question_lines == 0 then
    return
  end
  question_lines[1] = "You: " .. question_lines[1]
  for i = 2, #question_lines do
    question_lines[i] = "  " .. question_lines[i]
  end
  append_chat_lines(session.chat_buf, normalize_lines(question_lines))
  local thinking_line = vim.api.nvim_buf_line_count(session.chat_buf)
  append_chat_lines(session.chat_buf, { "Assistant: ⠋" })
  session.pending_spinner = start_chat_spinner(session.chat_buf, thinking_line)

  local placeholder_line = vim.api.nvim_buf_line_count(session.chat_buf) - 1
  local prompt_text = prompt.build_chat_prompt(question, session.context)

  request.run_command_raw(prompt_text, function(code, stdout, stderr)
    vim.schedule(function()
      if session.pending_spinner then
        session.pending_spinner.stop()
        session.pending_spinner = nil
      end
      if code ~= 0 then
        local msg = "Assistant: failed (exit " .. tostring(code) .. ")"
        if stderr and stderr ~= "" then
          msg = msg .. "\n" .. stderr
        end
        replace_chat_line(session.chat_buf, placeholder_line, { msg })
        util.notify("OpenCodeAsk: chat request failed", vim.log.levels.ERROR)
        return
      end

      local cleaned = stdout:gsub("\n+$", "")
      if cleaned == "" then
        replace_chat_line(session.chat_buf, placeholder_line, { "Assistant: (empty response)" })
        util.notify("OpenCodeAsk: empty response", vim.log.levels.WARN)
        return
      end

      local response_lines = vim.split(cleaned, "\n", { plain = true })
      response_lines[1] = "Assistant: " .. response_lines[1]
      for i = 2, #response_lines do
        response_lines[i] = "  " .. response_lines[i]
      end
      replace_chat_line(session.chat_buf, placeholder_line, normalize_lines(response_lines))
      append_chat_lines(session.chat_buf, { "" })
    end)
  end)
end

local function close_chat()
  if not state.chat_state then
    return
  end

  if state.chat_state.input_buf and vim.api.nvim_buf_is_valid(state.chat_state.input_buf) then
    vim.bo[state.chat_state.input_buf].modified = false
  end

  if state.chat_state.input_win and vim.api.nvim_win_is_valid(state.chat_state.input_win) then
    vim.api.nvim_win_close(state.chat_state.input_win, true)
  end
  if state.chat_state.chat_win and vim.api.nvim_win_is_valid(state.chat_state.chat_win) then
    vim.api.nvim_win_close(state.chat_state.chat_win, true)
  end

  state.chat_state.chat_win = nil
  state.chat_state.input_win = nil
end

local function attach_chat_autocmds(input_buf, chat_win, input_win)
  local group = vim.api.nvim_create_augroup("opencode_ask_chat_" .. input_buf, { clear = true })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = group,
    buffer = input_buf,
    callback = function()
      handle_chat_submit(input_buf)
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = input_buf,
    callback = function()
      pcall(vim.api.nvim_del_augroup_by_id, group)
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
      local win_id = tonumber(args.match)
      if win_id == chat_win or win_id == input_win then
        close_chat()
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
    group = group,
    buffer = input_buf,
    callback = function()
      highlight_buffer(input_buf)
    end,
  })
end

function M.chat(opts)
  if state.chat_state and state.chat_state.chat_win and vim.api.nvim_win_is_valid(state.chat_state.chat_win) then
    close_chat()
    return
  end

  local selection_ctx = selection.get_range_selection(opts)
  local source_buf = selection_ctx and selection_ctx.buf or vim.api.nvim_get_current_buf()
  if selection_ctx then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  end

  vim.schedule(function()
    setup_chat_highlights()
    local session = create_sidebar_windows()
    setup_chat_buffers(session.chat_buf, session.input_buf)
    setup_chat_window_options(session.chat_win)
    setup_input_window_options(session.input_win)

    local context = selection_ctx or selection.get_full_buffer_context(source_buf)
    if not context then
      util.notify("OpenCodeAsk: no context available", vim.log.levels.WARN)
      return
    end

    vim.b[session.input_buf].opencode_chat = {
      chat_buf = session.chat_buf,
      context = context,
    }

    state.chat_state = {
      chat_win = session.chat_win,
      input_win = session.input_win,
      chat_buf = session.chat_buf,
      input_buf = session.input_buf,
      context = context,
    }

    attach_chat_autocmds(session.input_buf, session.chat_win, session.input_win)

    vim.keymap.set("n", "q", function()
      close_chat()
    end, { buffer = session.input_buf, nowait = true })

    vim.keymap.set("n", "q", function()
      close_chat()
    end, { buffer = session.chat_buf, nowait = true })

    vim.keymap.set("n", "<CR>", function()
      handle_chat_submit(session.input_buf)
    end, { buffer = session.input_buf, nowait = true })

    vim.keymap.set("i", "<C-s>", function()
      handle_chat_submit(session.input_buf)
    end, { buffer = session.input_buf, nowait = true })

    local hint = build_selection_hint(selection_ctx)
    vim.api.nvim_buf_set_lines(session.input_buf, 0, -1, false, { hint })
    vim.bo[session.input_buf].modified = false
    completion.attach(session.input_buf)
    highlight_buffer(session.input_buf)
    if vim.api.nvim_win_is_valid(session.input_win) then
      vim.api.nvim_win_set_cursor(session.input_win, { 1, #hint })
    end
    vim.cmd("startinsert")
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(session.input_win) then
        vim.api.nvim_win_set_cursor(session.input_win, { 1, #hint })
      end
    end)
  end)
end

function M.chat_open(opts)
  if state.chat_state and state.chat_state.chat_win and vim.api.nvim_win_is_valid(state.chat_state.chat_win) then
    return
  end
  M.chat(opts)
end

function M.chat_close()
  close_chat()
end

return M
