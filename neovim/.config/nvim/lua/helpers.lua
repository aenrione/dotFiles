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

-- Command to toggle lines, relative numbers and cursorline
vim.api.nvim_create_user_command('ToggleLineNumbers', function()
  vim.wo.number = not vim.wo.number
  vim.wo.relativenumber = not vim.wo.relativenumber
  vim.wo.cursorline = not vim.wo.cursorline
  -- toggle GitSigns
  require('gitsigns').toggle_signs()
  -- toggle indent-blankline (IBLToggle)
  vim.cmd('IBLToggle')
  
end, {})

-- Command to reload the entire configuration file and plugins
vim.api.nvim_create_user_command('ReloadConfig', function()
 -- Unload all user configuration modules
    -- for name, _ in pairs(package.loaded) do
    --     if name:match('^config') or name:match('^helpers') or name:match('^keymaps') or name:match('^misc') or name:match('^options') or name:match('^plugins') then
    --         package.loaded[name] = nil
    --     end
    -- end

    -- Reload plugins using lazy.nvim
    -- require('lazy').sync()

    -- Reload main configuration files
    dofile(vim.fn.stdpath('config') .. '/lua/helpers.lua')
    dofile(vim.fn.stdpath('config') .. '/lua/keymaps.lua')
    dofile(vim.fn.stdpath('config') .. '/lua/misc.lua')
    dofile(vim.fn.stdpath('config') .. '/lua/options.lua')
    dofile(vim.fn.stdpath('config') .. '/init.lua')

    -- -- Reload plugin configuration files
    -- local plugin_files = vim.fn.glob(vim.fn.stdpath('config') .. '/lua/plugins/*.lua', true, true)
    -- for _, filepath in ipairs(plugin_files) do
    --     dofile(filepath)
    -- end
    --
    -- Reload all Lua files in the after/ directory
    local after_glob = vim.fn.stdpath('config') .. '/after/**/*.lua'
    local after_lua_filepaths = vim.fn.glob(after_glob, true, true)

    for _, filepath in ipairs(after_lua_filepaths) do
        dofile(filepath)
    end

    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)

end, {})



-- Command to create a new file
-- uses telescope to find the directory to create the file in and then prompts for the file name
vim.api.nvim_create_user_command('NewFile', function()
  require('telescope.builtin').file_browser({
    prompt_title = "Create new file",
    cwd = vim.fn.expand("%:p:h"),
    attach_mappings = function(prompt_bufnr, map)
      local new_file = function()
        local content = require('telescope.actions.state').get_selected_entry(prompt_bufnr)
        require('telescope.actions').close(prompt_bufnr)
        vim.cmd("edit " .. content.cwd .. "/" .. content.value)
      end

      map('i', '<CR>', new_file)
      map('n', '<CR>', new_file)

      return true
    end
  })
end, {})

