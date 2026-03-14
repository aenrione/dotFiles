local state = require("opencode_ask.state")

local M = {}

local function token_list()
  local cfg = state.config.completion or {}
  return cfg.context_tokens or { "@this", "@diff", "@diagnostics" }
end

local function remove_token(text, token)
  local updated = text:gsub(token, "")
  return vim.trim(updated)
end

function M.extract_tokens(text)
  local tokens = {}
  local cleaned = text
  for _, token in ipairs(token_list()) do
    if cleaned:find(token, 1, true) then
      table.insert(tokens, token)
      cleaned = remove_token(cleaned, token)
    end
  end
  return cleaned, tokens
end

local function format_this(selection)
  if not selection then
    return nil
  end
  local ft = vim.bo[selection.buf].filetype or ""
  return "Selected code:\n```" .. ft .. "\n" .. table.concat(selection.text, "\n") .. "\n```"
end

local function format_diff()
  local cwd = vim.fn.getcwd()
  local result = vim.system({ "git", "-C", cwd, "diff" }, { text = true }):wait()
  local diff = (result.code == 0 and result.stdout) or ""
  diff = diff:gsub("\n+$", "")
  if diff == "" then
    return "Diff: (no changes)"
  end
  return "Diff:\n```diff\n" .. diff .. "\n```"
end

local function format_diagnostics(buf)
  local diags = vim.diagnostic.get(buf)
  if not diags or #diags == 0 then
    return "Diagnostics: (none)"
  end

  local lines = {}
  for _, diag in ipairs(diags) do
    local severity = vim.diagnostic.severity[diag.severity] or tostring(diag.severity)
    local line = (diag.lnum or 0) + 1
    local col = (diag.col or 0) + 1
    table.insert(lines, string.format("%s %d:%d %s", severity, line, col, diag.message))
  end
  return "Diagnostics:\n" .. table.concat(lines, "\n")
end

function M.build_sections(tokens, selection, buf)
  local sections = {}
  for _, token in ipairs(tokens) do
    if token == "@this" then
      local section = format_this(selection)
      if section then
        table.insert(sections, section)
      end
    elseif token == "@diff" then
      table.insert(sections, format_diff())
    elseif token == "@diagnostics" then
      local target_buf = buf or (selection and selection.buf) or vim.api.nvim_get_current_buf()
      table.insert(sections, format_diagnostics(target_buf))
    end
  end
  return sections
end

return M
