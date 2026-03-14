local state = require("opencode_ask.state")
local client = require("opencode_ask.client")
local util = require("opencode_ask.util")

local M = {}

local function is_windows()
  return vim.fn.has("win32") == 1
end

local function parse_ports_from_lsof(stdout)
  local ports = {}
  for line in stdout:gmatch("[^\r\n]+") do
    local parts = vim.split(line, "%s+")
    if parts[1] ~= "COMMAND" then
      local port_str = parts[9] and parts[9]:match(":(%d+)$")
      if port_str then
        local port = tonumber(port_str)
        if port then
          table.insert(ports, port)
        end
      end
    end
  end
  return ports
end

local function get_ports_unix()
  local pgrep = vim.system({ "pgrep", "-f", "opencode.*--port" }, { text = true, env = util.build_env() }):wait()
  if pgrep.code ~= 0 or not pgrep.stdout or pgrep.stdout == "" then
    return {}
  end

  local ports = {}
  for line in pgrep.stdout:gmatch("[^\r\n]+") do
    local pid = tonumber(line)
    if pid then
      local lsof = vim
        .system({ "lsof", "-w", "-iTCP", "-sTCP:LISTEN", "-P", "-n", "-a", "-p", tostring(pid) }, { text = true })
        :wait()
      if lsof.code == 0 and lsof.stdout then
        for _, port in ipairs(parse_ports_from_lsof(lsof.stdout)) do
          table.insert(ports, port)
        end
      end
    end
  end

  return ports
end

local function get_ports()
  if is_windows() then
    return {}
  end
  return get_ports_unix()
end

local function start_server(port)
  local cmd = state.config.server and state.config.server.start_cmd
  local args
  if cmd and #cmd > 0 then
    args = cmd
  else
    args = { "opencode", "serve", "--port", tostring(port) }
  end

  if vim.fn.executable(args[1]) ~= 1 then
    return false, "opencode executable not found"
  end

  vim.fn.jobstart(args, { detach = true })
  return true
end

local function match_cwd(host, port, cwd)
  local ok, response = client.get_path_sync(host, port)
  if not ok or not response then
    return false
  end

  local server_cwd = response.directory or response.worktree
  if not server_cwd or server_cwd == "" then
    return false
  end

  return server_cwd:find(cwd, 1, true) == 1 or cwd:find(server_cwd, 1, true) == 1
end

local function probe_port(host, port)
  local ok, response = client.get_path_sync(host, port)
  if not ok or not response then
    return false
  end
  return true
end

function M.resolve()
  local cfg = state.config.server or {}
  local host = cfg.hostname or "127.0.0.1"

  if cfg.port then
    return { host = host, port = cfg.port }
  end

  local ports = get_ports()
  local start_port = cfg.start_port or 4096
  if #ports == 0 and probe_port(host, start_port) then
    ports = { start_port }
  end
  if #ports == 0 and cfg.auto_start then
    local ok, err = start_server(start_port)
    if ok then
      ports = { start_port }
    else
      return nil, err
    end
  end

  if #ports == 0 then
    return nil, "No opencode server found"
  end

  if #ports == 1 then
    return { host = host, port = ports[1] }
  end

  local cwd = vim.fn.getcwd()
  for _, port in ipairs(ports) do
    if match_cwd(host, port, cwd) then
      return { host = host, port = port }
    end
  end

  return { host = host, port = ports[1] }
end

return M
