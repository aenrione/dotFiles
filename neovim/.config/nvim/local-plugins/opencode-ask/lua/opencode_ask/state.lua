local M = {
  config = {},
  nsid = vim.api.nvim_create_namespace("opencode_ask"),
  request_id = 0,
  chat_state = nil,
  chat_highlights_set = false,
  server = nil,
  session_id = nil,
  provider_id = nil,
  model_id = nil,
  inflight = {},
  suppress_completion_once = false,
  events_job = nil,
  permission_pending = nil,
}

function M.set_config(cfg)
  M.config = cfg or {}
end

function M.next_request_id()
  M.request_id = M.request_id + 1
  return M.request_id
end

return M
