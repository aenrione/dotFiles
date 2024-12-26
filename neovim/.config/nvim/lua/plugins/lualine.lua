-- Get Repo
local function git_repo()
  local git_dir = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if string.find(git_dir, "fatal") then
    return ''
  end
  return vim.fn.fnamemodify(git_dir, ":t")
end

-- LSP status function
local lsp_status = {
  function()
    local buf_clients = vim.lsp.get_clients { bufnr = 0 }
    if #buf_clients == 0 then
      return "LSP Inactive"
    end

    local buf_ft = vim.bo.filetype
    local buf_client_names = {}
    local copilot_active = false

    -- add client
    for _, client in pairs(buf_clients) do
      if client.name ~= "null-ls" and client.name ~= "copilot" then
        table.insert(buf_client_names, client.name)
      end

      if client.name == "copilot" then
        copilot_active = true
      end
    end

    -- Add registered formatters
    local supported_formatters = {}
    local null_ls_sources = require("null-ls").get_sources()
    for _, source in ipairs(null_ls_sources) do
      if source.methods[1] == require("null-ls").methods.FORMATTING and vim.tbl_contains(source.filetypes, buf_ft) then
        table.insert(supported_formatters, source.name)
      end
    end
    vim.list_extend(buf_client_names, supported_formatters)

    -- Add registered linters
    local supported_linters = {}
    for _, source in ipairs(null_ls_sources) do
      if source.methods[1] == require("null-ls").methods.DIAGNOSTICS and vim.tbl_contains(source.filetypes, buf_ft) then
        table.insert(supported_linters, source.name)
      end
    end
    vim.list_extend(buf_client_names, supported_linters)

    local unique_client_names = table.concat(buf_client_names, ", ")
    local language_servers = string.format("[%s]", unique_client_names)

    if copilot_active then
      language_servers = language_servers .. "%#SLCopilot#" .. " " .. "" .. "%*"
    end

    return language_servers
  end,
  color = { gui = "bold" },
  cond = function()
    return vim.fn.winwidth(0) > 80
  end,
}


require('lualine').setup {
  options = {
    icons_enabled = true,
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_a = {
      { git_repo }, -- Add the git repo function here
      'branch'
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {
      -- {
      --   -- require("noice").api.statusline.mode.get,
      --   -- cond = require("noice").api.statusline.mode.has,
      --   -- color = { fg = "#ff9e64" },
      -- },
      -- {
      --   -- require("noice").api.status.command.get,
      --   -- cond = require("noice").api.status.command.has,
      --   -- color = { fg = "#ff9e64" },
      -- },
      'encoding', 'fileformat', 'filetype',
      lsp_status -- Add the LSP status function here
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'buffers'},
    lualine_y = {'filename'},
    lualine_z = { 'encoding', 'fileformat', 'filetype'}
  },
  tabline = {},
  winbar = {
    lualine_a = {{
      'buffers',
      symbols = {
        modified = ' ●',      -- Text to show when the buffer is modified
        alternate_file = '', -- Text to show to identify the alternate file
        directory =  '',     -- Text to show when the buffer is a directory
      },
      shorten = true,
    }},
  lualine_b = {},
  lualine_c = {},
  lualine_x = {},
  lualine_y = {},
  lualine_z = {},
},
inactive_winbar = {
  lualine_a = {},
  lualine_b = {},
  lualine_c = {},
  lualine_x = {},
  lualine_y = {},
  lualine_z = {}
},
  extensions = {}
}

