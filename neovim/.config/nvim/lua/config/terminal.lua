local M = {}
local Log = {
  debug = function(msg)
    print(msg) -- Replace this with your preferred logging method
  end,
}

M.config = function()
  return {
    active = true,
    on_config_done = nil,
    size = 20,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = false,
    direction = "float",
    close_on_exit = true,
    auto_scroll = true,
    shell = nil,
    float_opts = {
      border = "curved",
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
    winbar = {
      enabled = false,
    },
    execs = {
      { nil, "<M-1>", "Horizontal Terminal", "horizontal", 0.3 },
      { nil, "<M-2>", "Vertical Terminal", "vertical", 0.4 },
      { nil, "<M-3>", "Float Terminal", "float", nil },
    },
  }
end

local function get_buf_size()
  local cbuf = vim.api.nvim_get_current_buf()
  local bufinfo = vim.tbl_filter(function(buf)
    return buf.bufnr == cbuf
  end, vim.fn.getwininfo(vim.api.nvim_get_current_win()))[1]
  if bufinfo == nil then
    return { width = -1, height = -1 }
  end
  return { width = bufinfo.width, height = bufinfo.height }
end

local function get_dynamic_terminal_size(direction, size)
  size = size or M.config().size
  if direction ~= "float" and tostring(size):find(".", 1, true) then
    size = math.min(size, 1.0)
    local buf_sizes = get_buf_size()
    local buf_size = direction == "horizontal" and buf_sizes.height or buf_sizes.width
    return buf_size * size
  else
    return size
  end
end

M.init = function()
  for i, exec in pairs(M.config().execs) do
    local direction = exec[4] or M.config().direction

    local opts = {
      cmd = exec[1] or M.config().shell or vim.o.shell,
      keymap = exec[2],
      label = exec[3],
      count = i + 100,
      direction = direction,
      size = function()
        return get_dynamic_terminal_size(direction, exec[5])
      end,
    }

    M.add_exec(opts)
  end
end

M.setup = function()
  local terminal = require "toggleterm"
  terminal.setup(M.config())
  if M.config().on_config_done then
    M.config().on_config_done(terminal)
  end
end

M.add_exec = function(opts)
  local binary = opts.cmd:match "(%S+)"
  if vim.fn.executable(binary) ~= 1 then
    Log.debug("Skipping configuring executable " .. binary .. ". Please make sure it is installed properly.")
    return
  end

  vim.keymap.set({ "n", "t" }, opts.keymap, function()
    M._exec_toggle { cmd = opts.cmd, count = opts.count, direction = opts.direction, size = opts.size() }
  end, { desc = opts.label, noremap = true, silent = true })
end

M._exec_toggle = function(opts)
  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new { cmd = opts.cmd, count = opts.count, direction = opts.direction }
  term:toggle(opts.size, opts.direction)
end

M.toggle_log_view = function(logfile)
  local log_viewer = "less +F"
  Log.debug("attempting to open: " .. logfile)
  log_viewer = log_viewer .. " " .. logfile
  local term_opts = vim.tbl_deep_extend("force", M.config(), {
    cmd = log_viewer,
    open_mapping = "<c-\\>", -- Adjust as needed
    direction = "float",
    size = 20, -- Adjust as needed
    float_opts = {
      border = "curved",
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
  })

  local Terminal = require("toggleterm.terminal").Terminal
  local log_view = Terminal:new(term_opts)
  log_view:toggle()
end

M.lazygit_toggle = function()
  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit = Terminal:new {
    cmd = "lazygit",
    hidden = true,
    direction = "float",
    float_opts = {
      border = "none",
      width = 100000,
      height = 100000,
      zindex = 200,
    },
    on_open = function(_)
      vim.cmd "startinsert!"
    end,
    on_close = function(_) end,
    count = 99,
  }
  lazygit:toggle()
end

return M
