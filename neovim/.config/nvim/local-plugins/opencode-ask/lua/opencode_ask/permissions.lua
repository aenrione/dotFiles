local state = require("opencode_ask.state")
local util = require("opencode_ask.util")
local client = require("opencode_ask.client")
local server = require("opencode_ask.server")

local M = {}

local last_key_time = 0
local key_listener = nil

local function start_key_listener()
  if key_listener then
    return
  end
  key_listener = vim.on_key(function()
    last_key_time = vim.uv.now()
  end, vim.api.nvim_create_namespace("opencode_ask_permission_keys"))
end

local function stop_key_listener()
  if key_listener then
    vim.on_key(nil, key_listener)
    key_listener = nil
  end
end

local function wait_for_idle(delay_ms, callback)
  local function check()
    local now = vim.uv.now()
    if now - last_key_time >= delay_ms then
      callback()
      return
    end
    vim.defer_fn(check, delay_ms)
  end
  vim.defer_fn(check, delay_ms)
end

local function reply_permission(permission_id, reply)
  local server_info = server.resolve()
  if not server_info then
    util.notify("OpenCodeAsk: opencode server not found", vim.log.levels.ERROR)
    return
  end
  client.permit(server_info.host, server_info.port, permission_id, reply, function()
    state.permission_pending = nil
  end, function(_, msg)
    util.notify("OpenCodeAsk: failed to reply permission" .. (msg and ("\n" .. msg) or ""), vim.log.levels.ERROR)
  end)
end

local function handle_permission_asked(event)
  if state.permission_pending then
    return
  end
  state.permission_pending = event and event.properties and event.properties.id or event and event.id or nil
  if not state.permission_pending then
    return
  end

  local opts = state.config.events and state.config.events.permissions or {}
  if opts.enabled == false then
    return
  end

  start_key_listener()
  local delay = opts.idle_delay_ms or 500
  wait_for_idle(delay, function()
    stop_key_listener()
    vim.schedule(function()
      vim.ui.select({ "Once", "Always", "Reject" }, { prompt = "OpenCode permission" }, function(choice)
        if not choice then
          return
        end
        local reply = choice == "Always" and "always" or choice == "Reject" and "reject" or "once"
        reply_permission(state.permission_pending, reply)
      end)
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_autocmd("User", {
    pattern = "OpenCodeAskEvent:permission.asked",
    callback = function(args)
      handle_permission_asked(args.data)
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "OpenCodeAskEvent:permission.replied",
    callback = function()
      state.permission_pending = nil
    end,
  })
end

return M
