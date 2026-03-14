local M = {}

M.defaults = {
  server = {
    hostname = "127.0.0.1",
    port = nil,
    auto_start = true,
    start_port = 4096,
    auth = {
      username = "opencode",
      password = nil,
    },
  },
  provider = {
    provider_id = nil,
    model_id = nil,
    agent = nil,
    session_title = "opencode-ask",
  },
  include_file_context = true,
  notify = true,
  prompt_builder = nil,
  chat_prompt_builder = nil,
  chat_sidebar_width = 0.25,
  chat_input_height = 4,
  chat_use_float = true,
  chat_float_height = 0.98,
  chat_float_row = 0,
  chat_float_col_padding = 1,
  chat_border = "single",
  chat_winbar = true,
  chat_render_markdown = true,
  chat_conceallevel = 2,
  chat_concealcursor = "nc",
  completion = {
    enabled = true,
    max_items = 80,
    commands_dir = vim.fn.expand("~/.config/opencode/commands"),
    rules_dirs = {
      vim.fn.expand("~/.config/opencode/agents"),
      vim.fn.expand("~/.config/opencode/rules"),
    },
    skills_dirs = {
      vim.fn.expand("~/.config/opencode/skills"),
    },
    context_tokens = { "@this", "@diff", "@diagnostics" },
    wrap_files = false,
    trigger_files = "@",
    trigger_commands = "/",
    trigger_rules = "#",
  },
  rules = {
    project_dirs = { "rules", "skills", ".opencode/rules", ".opencode/skills" },
    project_files = { "AGENT.md" },
  },
  events = {
    permissions = {
      enabled = true,
      idle_delay_ms = 500,
    },
  },
}

function M.merge_config(opts)
  return vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
