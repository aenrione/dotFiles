local state = require("opencode_ask.state")

local M = {}

function M.notify(msg, level)
  if state.config.notify == false then
    return
  end
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO)
  end)
end

function M.build_env()
  return vim.fn.environ()
end

function M.get_ui_dimensions()
  local ui = vim.api.nvim_list_uis()[1]
  return ui.width, ui.height
end

function M.unique_buf_name(base)
  local name = base
  local idx = 1
  while true do
    local existing = vim.fn.bufnr(name)
    if existing == -1 or existing == 0 then
      return name
    end
    idx = idx + 1
    name = base .. "-" .. tostring(idx)
  end
end

return M
