local M = {}

local config = require("opencode_ask.config")
local state = require("opencode_ask.state")
local util = require("opencode_ask.util")
local selection = require("opencode_ask.selection")
local prompt = require("opencode_ask.prompt")
local request = require("opencode_ask.request")
local chat = require("opencode_ask.chat")
local events = require("opencode_ask.events")
local permissions = require("opencode_ask.permissions")

function M.ask_visual(opts)
  local selection_ctx = selection.get_range_selection(opts)
  if not selection_ctx then
    util.notify("OpenCodeAsk: visual selection required", vim.log.levels.WARN)
    return
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  vim.schedule(function()
    prompt.capture_prompt(selection_ctx, "")
  end)
end

function M.fill_visual(opts)
  local selection_ctx = selection.get_range_selection(opts)
  if not selection_ctx then
    util.notify("OpenCodeAsk: visual selection required", vim.log.levels.WARN)
    return
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  vim.schedule(function()
    local prompt_text = prompt.build_prompt("Fill in this code. Provide the complete implementation.", selection_ctx)
    request.run_command(prompt_text, selection_ctx)
  end)
end

function M.chat(opts)
  chat.chat(opts)
end

function M.chat_open(opts)
  chat.chat_open(opts)
end

function M.chat_close()
  chat.chat_close()
end

function M.setup(opts)
  state.set_config(config.merge_config(opts))
  permissions.setup()
  events.connect()
  vim.api.nvim_create_user_command("OpenCodeAsk", function(cmd_opts)
    M.ask_visual(cmd_opts)
  end, { range = true })
  vim.api.nvim_create_user_command("OpenCodeFill", function(cmd_opts)
    M.fill_visual(cmd_opts)
  end, { range = true })
  vim.api.nvim_create_user_command("OpenCodeChat", function(cmd_opts)
    M.chat(cmd_opts)
  end, { range = true })
  vim.api.nvim_create_user_command("OpenCodeChatOpen", function(cmd_opts)
    M.chat_open(cmd_opts)
  end, { range = true })
  vim.api.nvim_create_user_command("OpenCodeChatClose", function()
    M.chat_close()
  end, { range = true })
end

return M
