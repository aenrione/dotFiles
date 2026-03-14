local state = require("opencode_ask.state")
local util = require("opencode_ask.util")
local request = require("opencode_ask.request")
local completion = require("opencode_ask.completion")
local ctx = require("opencode_ask.context")
local highlight = require("opencode_ask.highlight")

local M = {}

local function create_centered_window_config()
  local width, height = util.get_ui_dimensions()
  local win_width = math.floor(width * 2 / 3)
  local win_height = math.floor(height / 3)
  return {
    width = win_width,
    height = win_height,
    row = math.floor((height - win_height) / 2),
    col = math.floor((width - win_width) / 2),
  }
end

local function create_floating_window(config, title)
  local buf_id = vim.api.nvim_create_buf(false, true)
  local win_id = vim.api.nvim_open_win(buf_id, true, {
    relative = "editor",
    width = config.width,
    height = config.height,
    row = config.row,
    col = config.col,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  })

  vim.wo[win_id].wrap = true
  vim.api.nvim_buf_set_name(buf_id, "opencode-ask-prompt")
  vim.bo[buf_id].filetype = "opencode_ask"
  vim.bo[buf_id].buftype = "acwrite"
  vim.bo[buf_id].bufhidden = "wipe"
  vim.bo[buf_id].swapfile = false

  return { win_id = win_id, buf_id = buf_id }
end

function M.build_prompt(instruction, selection)
  if type(state.config.prompt_builder) == "function" then
    return state.config.prompt_builder({
      instruction = instruction,
      selection = selection,
      file = vim.api.nvim_buf_get_name(selection.buf),
      filetype = vim.bo[selection.buf].filetype,
    })
  end

  local cleaned_instruction, tokens = ctx.extract_tokens(instruction)

  local parts = {}
  if state.config.include_file_context then
    local file = vim.api.nvim_buf_get_name(selection.buf)
    if file and file ~= "" then
      table.insert(parts, "File: " .. file)
    end
    local ft = vim.bo[selection.buf].filetype
    if ft and ft ~= "" then
      table.insert(parts, "Filetype: " .. ft)
    end
  end

  local sections = ctx.build_sections(tokens, selection, selection and selection.buf)
  for _, section in ipairs(sections) do
    table.insert(parts, section)
  end

  table.insert(parts, "Selected code:\n```" .. (vim.bo[selection.buf].filetype or "") .. "\n" .. table.concat(selection.text, "\n") .. "\n```")
  table.insert(parts, "Instruction: " .. cleaned_instruction)
  table.insert(parts, "Output requirements: Return only the replacement code for the selection. Do not include explanations, markdown fences, or commentary. Output must be code only.")
  return table.concat(parts, "\n\n")
end

function M.build_chat_prompt(question, context)
  if type(state.config.chat_prompt_builder) == "function" then
    return state.config.chat_prompt_builder({
      question = question,
      context = context,
      file = vim.api.nvim_buf_get_name(context.buf),
      filetype = vim.bo[context.buf].filetype,
    })
  end

  local cleaned_question, tokens = ctx.extract_tokens(question)

  local parts = {}
  if state.config.include_file_context then
    local file = vim.api.nvim_buf_get_name(context.buf)
    if file and file ~= "" then
      table.insert(parts, "File: " .. file)
    end
    local ft = vim.bo[context.buf].filetype
    if ft and ft ~= "" then
      table.insert(parts, "Filetype: " .. ft)
    end
  end

  local sections = ctx.build_sections(tokens, context, context and context.buf)
  for _, section in ipairs(sections) do
    table.insert(parts, section)
  end

  local label = context.is_full_buffer and "Current file:" or "Selected code:"
  table.insert(parts, label .. "\n```" .. (vim.bo[context.buf].filetype or "") .. "\n" .. table.concat(context.text, "\n") .. "\n```")
  table.insert(parts, "Question: " .. cleaned_question)
  return table.concat(parts, "\n\n")
end

function M.capture_prompt(selection, default_text)
  local config = create_centered_window_config()
  local win = create_floating_window(config, " OpenCode Ask ")

  if default_text and default_text ~= "" then
    vim.api.nvim_buf_set_lines(win.buf_id, 0, -1, false, vim.split(default_text, "\n"))
  end

  completion.attach(win.buf_id)
  highlight.apply_buffer(win.buf_id)
  vim.cmd("startinsert")

  local group = vim.api.nvim_create_augroup("opencode_ask_prompt_" .. win.buf_id, { clear = true })

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = group,
    buffer = win.buf_id,
    callback = function()
      if not vim.api.nvim_win_is_valid(win.win_id) then
        return
      end
      local lines = vim.api.nvim_buf_get_lines(win.buf_id, 0, -1, false)
      local instruction = table.concat(lines, "\n")
      vim.api.nvim_win_close(win.win_id, true)

      if instruction and instruction ~= "" then
        local prompt = M.build_prompt(instruction, selection)
        request.run_command(prompt, selection)
      end
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = tostring(win.win_id),
    callback = function()
      vim.api.nvim_del_augroup_by_id(group)
    end,
  })

  vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
    group = group,
    buffer = win.buf_id,
    callback = function()
      highlight.apply_buffer(win.buf_id)
    end,
  })

  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win.win_id) then
      vim.api.nvim_win_close(win.win_id, true)
    end
  end, { buffer = win.buf_id, nowait = true })

  vim.keymap.set("n", "<CR>", function()
    vim.cmd("write")
  end, { buffer = win.buf_id, nowait = true })

  vim.keymap.set("i", "<C-s>", function()
    vim.cmd("write")
  end, { buffer = win.buf_id, nowait = true })

  vim.keymap.set("n", "<Esc>", function()
    if vim.api.nvim_win_is_valid(win.win_id) then
      vim.api.nvim_win_close(win.win_id, true)
    end
  end, { buffer = win.buf_id, nowait = true })
end

return M
