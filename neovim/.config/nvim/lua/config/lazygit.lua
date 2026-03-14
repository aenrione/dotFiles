---@class lazygit.config
---@field config_dir? string
local M = {}

---@alias LazyGitColor {fg?:string, bg?:string, bold?:boolean}

---@class LazyGitTheme: table<number, LazyGitColor>
---@field activeBorderColor LazyGitColor
---@field cherryPickedCommitBgColor LazyGitColor
---@field cherryPickedCommitFgColor LazyGitColor
---@field defaultFgColor LazyGitColor
---@field inactiveBorderColor LazyGitColor
---@field optionsTextColor LazyGitColor
---@field searchingActiveBorderColor LazyGitColor
---@field selectedLineBgColor LazyGitColor
---@field unstagedChangesColor LazyGitColor
M.theme = {
  [241] = { fg = "Special" },
  activeBorderColor = { fg = "MatchParen", bold = true },
  cherryPickedCommitBgColor = { fg = "Identifier" },
  cherryPickedCommitFgColor = { fg = "Function" },
  defaultFgColor = { fg = "Normal" },
  inactiveBorderColor = { fg = "FloatBorder" },
  optionsTextColor = { fg = "Function" },
  searchingActiveBorderColor = { fg = "MatchParen", bold = true },
  selectedLineBgColor = { bg = "Visual" },
  unstagedChangesColor = { fg = "DiagnosticError" },
}

M.theme_path = vim.fn.stdpath("cache") .. "/lazygit-theme.yml"

if vim.g.lazygit_config == nil then
  vim.g.lazygit_config = true
end

M.dirty = true

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    M.dirty = true
  end,
})

local function hl_color(name, use_bg)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or not hl then
    return "default"
  end
  local color = use_bg and hl.bg or hl.fg
  if not color then
    return "default"
  end
  return string.format("#%06x", color)
end

function M.set_ansi_color(idx, color)
  io.write(("\27]4;%d;%s\7"):format(idx, color))
end

---@param v LazyGitColor
---@return string[]
function M.get_color(v)
  ---@type string[]
  local color = {}
  if v.fg then
    color[1] = hl_color(v.fg, false)
  elseif v.bg then
    color[1] = hl_color(v.bg, true)
  end
  if v.bold then
    table.insert(color, "bold")
  end
  return color
end

function M.update_config()
  ---@type table<string, string[]>
  local theme = {}

  for k, v in pairs(M.theme) do
    if type(k) == "number" then
      local color = M.get_color(v)
      pcall(M.set_ansi_color, k, color[1])
    else
      theme[k] = M.get_color(v)
    end
  end

  local config = [[
os:
  editPreset: "nvim-remote"
gui:
  nerdFontsVersion: 3
  theme:
]]

  ---@type string[]
  local lines = {}
  for k, v in pairs(theme) do
    lines[#lines + 1] = ("   %s:"):format(k)
    for _, c in ipairs(v) do
      lines[#lines + 1] = ("     - %q"):format(c)
    end
  end

  config = config .. table.concat(lines, "\n")
  vim.fn.mkdir(vim.fn.stdpath("cache"), "p")
  vim.fn.writefile(vim.split(config, "\n"), M.theme_path)
  M.dirty = false
end

function M.prepare()
  if vim.g.lazygit_theme ~= nil then
    vim.notify("vim.g.lazygit_theme is deprecated; use vim.g.lazygit_config", vim.log.levels.WARN)
  end

  if not vim.g.lazygit_config then
    return
  end

  if M.dirty then
    M.update_config()
  end

  if not M.config_dir then
    local lines = vim.fn.systemlist({ "lazygit", "-cd" })
    if vim.v.shell_error == 0 and lines[1] and lines[1] ~= "" then
      M.config_dir = lines[1]
      local config_path = M.config_dir .. "/config.yml"
      vim.env.LG_CONFIG_FILE = config_path .. "," .. M.theme_path
    else
      local err = table.concat(lines or {}, "\n")
      vim.notify(
        "Failed to get lazygit config directory. Will not apply lazygit config.\n" .. err,
        vim.log.levels.ERROR
      )
    end
  end
end

return M
