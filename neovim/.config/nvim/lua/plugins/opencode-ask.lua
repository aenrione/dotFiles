return {
  dir = vim.fn.stdpath("config") .. "/local-plugins/opencode-ask",
  name = "opencode-ask",
  config = function()
    require("opencode_ask").setup({
      command = vim.fn.expand("~/tools/opencode-ask/bin/ask"),
      args = { "--no-render", "--full" },
      bun_dir = vim.fn.expand("~/.bun/bin"),
      context = {
        enabled = true,
        prompt = "Context (optional)",
        default = "",
      },
      instruction_prompt = "What should I do?",
      include_file_context = true,
      notify = true,
    })
  end,
}
