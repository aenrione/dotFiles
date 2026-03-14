local M = {}

local function find_conflict(bufnr, cursor_line)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local start = cursor_line
  while start >= 1 and not lines[start]:match("^<<<<<<<") do
    start = start - 1
  end
  if start < 1 then
    return nil
  end

  local middle = nil
  local finish = nil
  for i = start + 1, #lines do
    if not middle and lines[i]:match("^=======") then
      middle = i
    elseif lines[i]:match("^>>>>>>>") then
      finish = i
      break
    end
  end

  if not middle or not finish then
    return nil
  end

  return {
    start = start,
    middle = middle,
    finish = finish,
  }
end

local function replace_conflict(bufnr, range, replacement)
  local start0 = range.start - 1
  local finish0 = range.finish - 1
  vim.api.nvim_buf_set_lines(bufnr, start0, finish0 + 1, false, replacement)
end

local function get_conflict_sides(bufnr, range)
  local start0 = range.start - 1
  local middle0 = range.middle - 1
  local finish0 = range.finish - 1
  local ours = vim.api.nvim_buf_get_lines(bufnr, start0 + 1, middle0, false)
  local theirs = vim.api.nvim_buf_get_lines(bufnr, middle0 + 1, finish0, false)
  return ours, theirs
end

function M.choose(which)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local range = find_conflict(bufnr, cursor_line)

  if not range then
    vim.notify("No conflict markers found near cursor", vim.log.levels.WARN)
    return
  end

  local ours, theirs = get_conflict_sides(bufnr, range)
  local replacement = {}

  if which == "ours" then
    replacement = ours
  elseif which == "theirs" then
    replacement = theirs
  elseif which == "both" then
    replacement = vim.list_extend(vim.deepcopy(ours), theirs)
  elseif which == "none" then
    replacement = {}
  else
    vim.notify("Unknown conflict choice: " .. tostring(which), vim.log.levels.ERROR)
    return
  end

  replace_conflict(bufnr, range, replacement)
end

function M.choose_ours()
  M.choose("ours")
end

function M.choose_theirs()
  M.choose("theirs")
end

function M.choose_both()
  M.choose("both")
end

function M.choose_none()
  M.choose("none")
end

function M.next_conflict()
  local found = vim.fn.search("^=======", "W")
  if found == 0 then
    vim.notify("No next conflict separator found", vim.log.levels.WARN)
  end
end

function M.prev_conflict()
  local found = vim.fn.search("^=======", "bW")
  if found == 0 then
    vim.notify("No previous conflict separator found", vim.log.levels.WARN)
  end
end

vim.api.nvim_create_user_command("ConflictChooseOurs", function()
  M.choose_ours()
end, {})

vim.api.nvim_create_user_command("ConflictChooseTheirs", function()
  M.choose_theirs()
end, {})

vim.api.nvim_create_user_command("ConflictChooseBoth", function()
  M.choose_both()
end, {})

vim.api.nvim_create_user_command("ConflictChooseNone", function()
  M.choose_none()
end, {})

vim.api.nvim_create_user_command("ConflictNext", function()
  M.next_conflict()
end, {})

vim.api.nvim_create_user_command("ConflictPrev", function()
  M.prev_conflict()
end, {})

return M
