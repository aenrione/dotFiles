local M = {}

function M.get_range_selection(opts)
  local buf = vim.api.nvim_get_current_buf()
  if not opts or opts.range == 0 then
    return nil
  end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  if start_pos[2] == 0 or end_pos[2] == 0 then
    local start_row = (opts.line1 or 1) - 1
    local end_row = (opts.line2 or opts.line1 or 1) - 1
    local lines = vim.api.nvim_buf_get_lines(buf, start_row, end_row + 1, false)
    local end_col = #((lines[#lines]) or "")
    return {
      buf = buf,
      start_row = start_row,
      start_col = 0,
      end_row = end_row,
      end_col = end_col,
      text = lines,
    }
  end

  local start_row = start_pos[2] - 1
  local start_col = start_pos[3] - 1
  local end_row = end_pos[2] - 1
  local end_col = end_pos[3]

  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  local text = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})
  return {
    buf = buf,
    start_row = start_row,
    start_col = start_col,
    end_row = end_row,
    end_col = end_col,
    text = text,
  }
end

function M.get_full_buffer_context(buf)
  local text = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return {
    buf = buf,
    text = text,
    is_full_buffer = true,
  }
end

return M
