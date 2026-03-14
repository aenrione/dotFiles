local state = require("opencode_ask.state")

local M = {}

local function trim_extension(name)
  local trimmed = name:gsub("%.[^%.]+$", "")
  return trimmed
end

local function list_files_in_dir(dir)
  if not dir or dir == "" then
    return {}
  end
  local files = vim.fn.globpath(dir, "*", false, true)
  local items = {}
  for _, path in ipairs(files) do
    local name = vim.fn.fnamemodify(path, ":t")
    table.insert(items, trim_extension(name))
  end
  return items
end

local function list_project_rules()
  local cfg = state.config.rules or {}
  local cwd = vim.fn.getcwd()
  local items = {}
  local seen = {}

  for _, dir in ipairs(cfg.project_dirs or {}) do
    local path = cwd .. "/" .. dir
    if vim.fn.isdirectory(path) == 1 then
      for _, name in ipairs(list_files_in_dir(path)) do
        if not seen[name] then
          table.insert(items, name)
          seen[name] = true
        end
      end
    end
  end

  for _, filename in ipairs(cfg.project_files or {}) do
    local path = cwd .. "/" .. filename
    if vim.fn.filereadable(path) == 1 then
      local name = trim_extension(vim.fn.fnamemodify(path, ":t"))
      if not seen[name] then
        table.insert(items, name)
        seen[name] = true
      end
    end
  end

  return items
end

local function list_global_rules()
  local completion = state.config.completion or {}
  local items = {}
  local seen = {}

  for _, dir in ipairs(completion.rules_dirs or {}) do
    for _, name in ipairs(list_files_in_dir(dir)) do
      if not seen[name] then
        table.insert(items, name)
        seen[name] = true
      end
    end
  end

  for _, dir in ipairs(completion.skills_dirs or {}) do
    for _, name in ipairs(list_files_in_dir(dir)) do
      if not seen[name] then
        table.insert(items, name)
        seen[name] = true
      end
    end
  end

  return items
end

function M.list_rule_names()
  local items = {}
  local seen = {}

  for _, name in ipairs(list_project_rules()) do
    if not seen[name] then
      table.insert(items, name)
      seen[name] = true
    end
  end

  for _, name in ipairs(list_global_rules()) do
    if not seen[name] then
      table.insert(items, name)
      seen[name] = true
    end
  end

  return items
end

return M
