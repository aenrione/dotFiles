local state = require("opencode_ask.state")
local util = require("opencode_ask.util")
local client = require("opencode_ask.client")
local server = require("opencode_ask.server")
local throbber = require("opencode_ask.throbber")

local M = {}

local function set_loading_mark(selection, mark_id, text)
  if not vim.api.nvim_buf_is_valid(selection.buf) then
    return
  end
  vim.api.nvim_buf_set_extmark(selection.buf, state.nsid, selection.start_row, 0, {
    virt_text = { { text, "Comment" } },
    virt_text_pos = "eol",
    id = mark_id,
  })
end

local function show_loading(selection)
  local mark_id = state.next_request_id()
  set_loading_mark(selection, mark_id, " ⠋ ")
  local spinner = throbber.start({
    interval = 120,
    on_tick = function(frame)
      set_loading_mark(selection, mark_id, " " .. frame .. " ")
    end,
  })
  return { mark_id = mark_id, spinner = spinner }
end

local function clear_loading(selection, mark_id)
  if mark_id then
    pcall(vim.api.nvim_buf_del_extmark, selection.buf, state.nsid, mark_id)
  end
end

local function replace_selection(selection, new_text)
  local line = vim.api.nvim_buf_get_lines(selection.buf, selection.end_row, selection.end_row + 1, false)[1] or ""
  local max_col = #line
  if selection.end_col > max_col then
    selection.end_col = max_col
  end
  if selection.start_col > max_col then
    selection.start_col = max_col
  end
  local lines = vim.split(new_text, "\n", { plain = true })
  vim.api.nvim_buf_set_text(
    selection.buf,
    selection.start_row,
    selection.start_col,
    selection.end_row,
    selection.end_col,
    lines
  )
end

local function extract_code_only(response)
  local blocks = {}
  for block in response:gmatch("```[a-zA-Z0-9_-]*\n(.-)\n```") do
    table.insert(blocks, block)
  end
  if #blocks > 0 then
    return blocks[1]
  end
  return response
end

local function looks_like_code(line)
  if line:match("^%s*$") then
    return false
  end
  if line:match("^%s*[{}]") then
    return true
  end
  if line:match("^%s*[%w_]+%s*=%s*") then
    return true
  end
  if line:match("^%s*[%w_]+%s*:%s*[%w_%[%]]") then
    return true
  end
  if line:match("^%s*(local|const|let|var|function|if|for|while|return|class|import|export|type|interface)\b") then
    return true
  end
  if line:find("=>", 1, true) or line:find(";", 1, true) then
    return true
  end
  return false
end

local function strip_leading_commentary(response)
  local lines = vim.split(response, "\n", { plain = true })
  local start_idx = 1
  for i, line in ipairs(lines) do
    if looks_like_code(line) then
      start_idx = i
      break
    end
  end
  local trimmed = {}
  for i = start_idx, #lines do
    table.insert(trimmed, lines[i])
  end
  return table.concat(trimmed, "\n")
end

local function extract_response_text(payload)
  if not payload then
    return ""
  end
  if type(payload) == "string" then
    return payload
  end
  local parts = payload.parts or payload
  if type(parts) ~= "table" then
    return ""
  end
  local chunks = {}
  for _, part in ipairs(parts) do
    if type(part) == "table" then
      if part.text and part.text ~= "" then
        table.insert(chunks, part.text)
      elseif part.content and type(part.content) == "string" then
        table.insert(chunks, part.content)
      end
    end
  end
  return table.concat(chunks, "\n")
end

local function ensure_server()
  if state.server then
    return state.server
  end
  local resolved, err = server.resolve()
  if not resolved then
    util.notify("OpenCodeAsk: " .. (err or "opencode server not found"), vim.log.levels.ERROR)
    return nil
  end
  state.server = resolved
  return resolved
end


local function ensure_session(server_info, on_ready)
  if state.session_id then
    on_ready(state.session_id)
    return
  end
  local title = (state.config.provider and state.config.provider.session_title) or "opencode-ask"
  client.create_session(server_info.host, server_info.port, title, function(response)
    if response and response.id then
      state.session_id = response.id
      on_ready(response.id)
    else
      util.notify("OpenCodeAsk: failed to create session", vim.log.levels.ERROR)
    end
  end, function(_, msg)
    util.notify("OpenCodeAsk: failed to create session" .. (msg and ("\n" .. msg) or ""), vim.log.levels.ERROR)
  end)
end

function M.run_command_raw(prompt, on_done)
  local server_info = ensure_server()
  if not server_info then
    return
  end

  ensure_session(server_info, function(session_id)
    local provider_cfg = state.config.provider or {}
    local opts = {}
    if provider_cfg.model_id then
      opts.model_id = provider_cfg.model_id
    end
    if provider_cfg.agent then
      opts.agent = provider_cfg.agent
    end
    client.send_message(server_info.host, server_info.port, session_id, prompt, opts, function(response)
      local text = extract_response_text(response)
      on_done(0, text or "", "")
    end, function(code, msg)
      on_done(code or 1, "", msg or "")
    end)
  end)
end

function M.run_command(prompt, selection)
  local loading = show_loading(selection)
  local request_id = state.next_request_id()
  state.inflight[request_id] = { selection = selection, mark_id = loading.mark_id, spinner = loading.spinner }
  M.run_command_raw(prompt, function(code, stdout, stderr)
    vim.schedule(function()
      local inflight = state.inflight[request_id]
      state.inflight[request_id] = nil
      if inflight and inflight.spinner then
        inflight.spinner.stop()
      end
      if inflight then
        clear_loading(inflight.selection, inflight.mark_id)
      else
        clear_loading(selection, loading.mark_id)
      end
      if code ~= 0 then
        local msg = "OpenCodeAsk: failed (exit " .. tostring(code) .. ")"
        if stderr and stderr ~= "" then
          msg = msg .. "\n" .. stderr
        end
        util.notify(msg, vim.log.levels.ERROR)
        return
      end

      local cleaned = stdout:gsub("\n+$", "")
      if cleaned == "" then
        util.notify("OpenCodeAsk: empty response", vim.log.levels.WARN)
        return
      end

      local extracted = extract_code_only(cleaned)
      if extracted == cleaned then
        extracted = strip_leading_commentary(extracted)
      end
      local code_only = extracted:gsub("^%s+", ""):gsub("%s+$", "")
      if code_only == "" then
        util.notify("OpenCodeAsk: no code in response", vim.log.levels.WARN)
        return
      end

      if not vim.api.nvim_buf_is_valid(selection.buf) then
        util.notify("OpenCodeAsk: target buffer no longer valid", vim.log.levels.WARN)
        return
      end

      replace_selection(selection, code_only)
    end)
  end)
end

return M
