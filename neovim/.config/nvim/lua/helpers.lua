local function search_config()
  local search_path = vim.fn.expand("~/.config/nvim")

  print("Searching in: " .. search_path)

  local success, _ = pcall(require('telescope.builtin').find_files, {
    prompt_title = "Search local Neovim config ",
    cwd = search_path,
  })

  if not success then
    print("Failed to open Telescope in: " .. search_path)
  end
end

function _G.search_local_lvim()
  search_config()
end

vim.api.nvim_create_user_command('LocalNvimConfig', function()
  search_config()
end, {})

