local state = require("opencode_ask.state")

local M = {}

local nsid = vim.api.nvim_create_namespace("opencode_ask_highlight")
local hl_set = false

local function ensure_highlights()
  if hl_set then
    return
  end
  hl_set = true
  vim.api.nvim_set_hl(0, "OpenCodeChatPath", { fg = "#e5c07b" })
  vim.api.nvim_set_hl(0, "OpenCodeChatContext", { fg = "#c678dd" })
  vim.api.nvim_set_hl(0, "OpenCodeChatCommand", { fg = "#98c379" })
end

local function highlight_line(buf, line_nr, text)
  vim.api.nvim_buf_clear_namespace(buf, nsid, line_nr, line_nr + 1)
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
      vim.api.nvim_buf_set_extmark(buf, nsid, line_nr, start_col - 1, {
        end_col = end_col - 1,
        hl_group = hl,
      })
    end
  end
end

function M.apply_line(buf, line_nr, text)
  ensure_highlights()
  highlight_line(buf, line_nr, text)
end

function M.apply_buffer(buf)
  ensure_highlights()
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    highlight_line(buf, i - 1, line)
  end
end

return M
