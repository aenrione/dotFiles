-- Check for compatible Neovim version
if vim.fn.has('nvim-0.5') == 0 then
  return
end

-- Only load once
if vim.g.loaded_bclose then
  return
end
vim.g.loaded_bclose = 1

if vim.g.bclose_multiple == nil then
  vim.g.bclose_multiple = 1
end

-- Display an error message
local function Warn(msg)
  vim.api.nvim_echo({{msg, 'ErrorMsg'}}, true, {})
end

-- Command ':Bclose' implementation
local function Bclose(bang, buffer)
  local btarget
  if buffer == nil or buffer == '' then
    btarget = vim.fn.bufnr('%')
  elseif tonumber(buffer) ~= nil then
    btarget = vim.fn.bufnr(tonumber(buffer))
  else
    btarget = vim.fn.bufnr(buffer)
  end

  if btarget < 0 then
    Warn('No matching buffer for ' .. buffer)
    return
  end

  if bang == '' and vim.api.nvim_buf_get_option(btarget, 'modified') then
    Warn('No write since last change for buffer ' .. btarget .. ' (use :Bclose!)')
    return
  end

  -- Numbers of windows that view target buffer which we will delete.
  local wnums = {}
  for i = 1, vim.fn.winnr('$') do
    if vim.fn.winbufnr(i) == btarget then
      table.insert(wnums, i)
    end
  end

  if not vim.g.bclose_multiple and #wnums > 1 then
    Warn('Buffer is in multiple windows (use ":let bclose_multiple=1")')
    return
  end

  local wcurrent = vim.fn.winnr()

  -- Check if this is the last window
  if vim.fn.winnr('$') == 1 then
    Warn('Cannot close the last window')
    return
  end

  for _, w in ipairs(wnums) do
    vim.cmd(w .. 'wincmd w')
    local prevbuf = vim.fn.bufnr('#')
    if prevbuf > 0 and vim.fn.buflisted(prevbuf) and prevbuf ~= btarget then
      vim.cmd('buffer #')
    else
      vim.cmd('bprevious')
    end

    if btarget == vim.fn.bufnr('%') then
      -- Numbers of listed buffers which are not the target to be deleted.
      local blisted = {}
      for i = 1, vim.fn.bufnr('$') do
        if vim.fn.buflisted(i) == 1 and i ~= btarget then
          table.insert(blisted, i)
        end
      end

      -- Listed, not target, and not displayed.
      local bhidden = {}
      for _, b in ipairs(blisted) do
        if vim.fn.bufwinnr(b) < 0 then
          table.insert(bhidden, b)
        end
      end

      -- Take the first buffer, if any (could be more intelligent).
      local bjump = (bhidden[1] or blisted[1] or -1)
      if bjump > 0 then
        vim.cmd('buffer ' .. bjump)
      else
        vim.cmd('enew' .. bang)
      end
    end
  end

  vim.cmd('bdelete' .. (bang and '!' or '') .. ' ' .. btarget)
  vim.cmd(wcurrent .. 'wincmd w')
end

-- Add the Bclose command
vim.api.nvim_create_user_command('Bclose', function(opts)
  Bclose(opts.bang, opts.args)
end, { bang = true, complete = 'buffer', nargs = '?' })
