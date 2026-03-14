local state = require("opencode_ask.state")
local util = require("opencode_ask.util")

local M = {}

local function build_url(host, port, path)
  return "http://" .. host .. ":" .. tostring(port) .. path
end

local function build_auth_args()
  local auth = state.config.server and state.config.server.auth or {}
  if not auth or not auth.password or auth.password == "" then
    return {}
  end
  local username = auth.username or "opencode"
  return { "-u", username .. ":" .. auth.password }
end

local function decode_json(payload)
  if not payload or payload == "" then
    return true, nil
  end
  local trimmed = vim.trim(payload)
  local ok, decoded
  if vim.json and vim.json.decode then
    ok, decoded = pcall(vim.json.decode, trimmed)
  else
    ok, decoded = pcall(vim.fn.json_decode, trimmed)
  end
  return ok, decoded
end

local function encode_json(payload)
  if not payload then
    return nil
  end
  if vim.json and vim.json.encode then
    return vim.json.encode(payload)
  end
  return vim.fn.json_encode(payload)
end

function M.call(host, port, path, method, body, on_success, on_error)
  local args = {
    "curl",
    "-s",
    "--connect-timeout",
    "1",
    "-X",
    method,
    "-H",
    "Content-Type: application/json",
    "-H",
    "Accept: application/json",
  }

  for _, arg in ipairs(build_auth_args()) do
    table.insert(args, arg)
  end

  if body then
    table.insert(args, "-d")
    table.insert(args, encode_json(body))
  end

  table.insert(args, build_url(host, port, path))

  vim.system(args, { text = true, env = util.build_env() }, function(obj)
    if obj.code ~= 0 then
      if on_error then
        on_error(obj.code, obj.stderr)
      end
      return
    end

    local ok, decoded = decode_json(obj.stdout)
    if not ok then
      if on_error then
        on_error(obj.code, "Failed to decode response")
      end
      return
    end

    if on_success then
      on_success(decoded)
    end
  end)
end

function M.call_sync(host, port, path, method, body)
  local args = {
    "curl",
    "-s",
    "--connect-timeout",
    "1",
    "-X",
    method,
    "-H",
    "Content-Type: application/json",
    "-H",
    "Accept: application/json",
  }

  for _, arg in ipairs(build_auth_args()) do
    table.insert(args, arg)
  end

  if body then
    table.insert(args, "-d")
    table.insert(args, encode_json(body))
  end

  table.insert(args, build_url(host, port, path))

  local result = vim.system(args, { text = true, env = util.build_env() }):wait()
  if result.code ~= 0 then
    return false, result.stderr
  end

  local ok, decoded = decode_json(result.stdout)
  if not ok then
    return false, "Failed to decode response"
  end
  return true, decoded
end

function M.get_path_sync(host, port)
  return M.call_sync(host, port, "/path", "GET")
end

function M.get_config_providers(host, port, callback, on_error)
  M.call(host, port, "/config/providers", "GET", nil, callback, on_error)
end

function M.create_session(host, port, title, callback, on_error)
  local body = {}
  if title and title ~= "" then
    body.title = title
  end
  M.call(host, port, "/session", "POST", body, callback, on_error)
end

function M.send_message(host, port, session_id, prompt, opts, callback, on_error)
  local body = {
    parts = {
      {
        type = "text",
        text = prompt,
      },
    },
  }

  if opts and opts.model_id then
    body.model = opts.model_id
  end
  if opts and opts.agent then
    body.agent = opts.agent
  end

  local path = "/session/" .. session_id .. "/message"
  M.call(host, port, path, "POST", body, callback, on_error)
end

function M.permit(host, port, permission_id, reply, callback, on_error)
  local body = { reply = reply }
  local path = "/permission/" .. permission_id .. "/reply"
  M.call(host, port, path, "POST", body, callback, on_error)
end

return M
