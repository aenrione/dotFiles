local M = {}

local throb_icons = {
  { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  { "◐", "◓", "◑", "◒" },
  { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
  { "◰", "◳", "◲", "◱" },
  { "◜", "◠", "◝", "◞", "◡", "◟" },
}

local function pick_frames()
  math.randomseed(tonumber(vim.uv.now()))
  return throb_icons[math.random(#throb_icons)]
end

function M.start(opts)
  opts = opts or {}
  local frames = opts.frames or pick_frames()
  local interval = opts.interval or 120
  local on_tick = opts.on_tick or function() end
  local on_stop = opts.on_stop or function() end
  local idx = 1
  local running = true

  local function tick()
    if not running then
      on_stop()
      return
    end
    on_tick(frames[idx])
    idx = (idx % #frames) + 1
    vim.defer_fn(tick, interval)
  end

  vim.defer_fn(tick, interval)

  return {
    stop = function()
      running = false
    end,
  }
end

return M
