local state = require("opencode_ask.state")
local server = require("opencode_ask.server")
local util = require("opencode_ask.util")

local M = {}

local function build_auth_args()
  local auth = state.config.server and state.config.server.auth or {}
  if not auth or not auth.password or auth.password == "" then
    return {}
  end
  local username = auth.username or "opencode"
  return { "-u", username .. ":" .. auth.password }
end

local function dispatch_event(event)
  if not event or not event.type then
    return
  end
  vim.schedule(function()
    vim.api.nvim_exec_autocmds("User", {
      pattern = "OpenCodeAskEvent:" .. event.type,
      data = event,
    })
  end)
end

local function decode_event(payload)
  if not payload or payload == "" then
    return nil
  end
  local trimmed = vim.trim(payload)
  local ok, decoded
  if vim.json and vim.json.decode then
    ok, decoded = pcall(vim.json.decode, trimmed)
  else
    ok, decoded = pcall(vim.fn.json_decode, trimmed)
  end
  if not ok then
    return nil
  end
  return decoded
end

function M.connect()
  if state.events_job then
    return
  end

  local server_info, err = server.resolve()
  if not server_info then
    util.notify("OpenCodeAsk: " .. (err or "opencode server not found"), vim.log.levels.ERROR)
    return
  end

  local args = {
    "curl",
    "-s",
    "--connect-timeout",
    "1",
    "-H",
    "Accept: text/event-stream",
    "-N",
  }
  for _, arg in ipairs(build_auth_args()) do
    table.insert(args, arg)
  end
  table.insert(args, "http://" .. server_info.host .. ":" .. tostring(server_info.port) .. "/event")

  local response_buffer = {}
  local function process_buffer()
    if #response_buffer == 0 then
      return
    end
    local full_event = table.concat(response_buffer)
    response_buffer = {}
    local decoded = decode_event(full_event)
    if decoded then
      dispatch_event(decoded)
    end
  end

  state.events_job = vim.fn.jobstart(args, {
    on_stdout = function(_, data)
      if not data then
        return
      end
      for _, line in ipairs(data) do
        if line == "" then
          process_buffer()
        else
          local clean = line:gsub("^data:%s*", "")
          table.insert(response_buffer, clean)
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            util.notify("OpenCodeAsk: event stream error\n" .. line, vim.log.levels.WARN)
          end
        end
      end
    end,
    on_exit = function()
      state.events_job = nil
    end,
  })
end

function M.disconnect()
  if state.events_job then
    pcall(vim.fn.jobstop, state.events_job)
    state.events_job = nil
  end
end

return M
