local function search_rails(type)
  local search_path = vim.fn.getcwd() .. "/app/" .. type
  if type == "db/migrate" then
    search_path = vim.fn.getcwd() .. "/db/migrate"
  end

  -- Debug: Print the search path
  print("Searching in: " .. search_path)

  local success, _ = pcall(require('telescope.builtin').find_files, {
    prompt_title = "Search Rails " .. type,
    cwd = search_path,
  })

  if not success then
    print("Failed to open Telescope in: " .. search_path)
  end
end

function _G.search_rails(type)
  search_rails(type)
end

vim.api.nvim_create_user_command('RailsModels', function()
  search_rails("models")
end, {})

vim.api.nvim_create_user_command('RailsHelpers', function()
  search_rails("helpers")
end, {})

vim.api.nvim_create_user_command('RailsSerializers', function()
  search_rails("serializers")
end, {})

vim.api.nvim_create_user_command('RailsControllers', function()
  search_rails("controllers")
end, {})

vim.api.nvim_create_user_command('RailsMigrations', function()
  search_rails("db/migrate")
end, {})

vim.api.nvim_create_user_command('RailsViews', function()
  search_rails("views")
end, {})

vim.api.nvim_create_user_command('RailsJavascript', function()
  search_rails("javascript")
end, {})

local function list_microservices()
  local path = vim.fn.getcwd() .. "/microservices"
  local dirs = vim.fn.split(vim.fn.globpath(path, '*/'), '\n')
  for i, dir in ipairs(dirs) do
    local last_directory = dir:match(".*/([^/]+)/?$")
    dirs[i] = last_directory
  end
  return dirs
end

local function search_in_microservice(subdir)
  local microservices = list_microservices()
  require('telescope.pickers').new({}, {
    prompt_title = "Select Microservice",
    finder = require('telescope.finders').new_table({
      results = microservices,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry,
          ordinal = entry,
        }
      end
    }),
    sorter = require('telescope.config').values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<CR>', function()
        local selection = require('telescope.actions.state').get_selected_entry()
        require('telescope.actions').close(prompt_bufnr)
        local search_path = vim.fn.getcwd() .. '/microservices/' .. selection.value .. '/' .. subdir
        require('telescope.builtin').find_files({
          prompt_title = "Search " .. subdir .. " in " .. selection.value,
          cwd = search_path,
        })
      end)
      map('n', '<CR>', function()
        local selection = require('telescope.actions.state').get_selected_entry()
        require('telescope.actions').close(prompt_bufnr)
        local search_path = vim.fn.getcwd() .. '/microservices/' .. selection.value .. '/' .. subdir
        require('telescope.builtin').find_files({
          prompt_title = "Search " .. subdir .. " in " .. selection.value,
          cwd = search_path,
        })
      end)
      return true
    end
  }):find()
end

-- User commands for specific directories
vim.api.nvim_create_user_command('SearchMicroserviceModels', function()
  search_in_microservice("app/models")
end, {})

vim.api.nvim_create_user_command('SearchMicroserviceControllers', function()
  search_in_microservice("app/controllers")
end, {})

vim.api.nvim_create_user_command('SearchMicroserviceSerializers', function()
  search_in_microservice("app/serializers")
end, {})

vim.api.nvim_create_user_command('SearchMicroserviceHelpers', function()
  search_in_microservice("app/helpers")
end, {})

vim.api.nvim_create_user_command('SearchMicroserviceMigrations', function()
  search_in_microservice("db/migrate")
end, {})

vim.api.nvim_create_user_command('SearchMicroserviceViews', function()
  search_in_microservice("app/views")
end, {})



function RunRuboCop()
  local filename = vim.fn.expand('%:p')
  local command = "rubocop -a " .. filename
  local output = vim.fn.system(command)
  -- print(output)
end

-- run command and run :e to reload the file
vim.cmd([[command! RunRuboCop :lua RunRuboCop() | e]])

