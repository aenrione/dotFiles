-- Install lazylazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Fixes Notify opacity issues
vim.o.termguicolors = true

require('lazy').setup({
  { "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...},
  "nvim-neotest/nvim-nio",
  {
    'dense-analysis/ale',
    config = function()
        local g = vim.g
        g.ale_linters = {
            ruby = {'rubocop', 'ruby'},
            lua = {'lua_language_server'},
            javascript = {'eslint', 'prettier'},
        }
        g.ale_fixers = {
            ruby = {'rubocop'},
            lua = {'lua_format'},
            javascript = {'prettier', 'eslint'},
        }
    end
  },
  {
    "folke/which-key.nvim",
    tag = "v2.1.0",
    config = function()
      require("plugins.which-key").setup()
    end,
    cmd = "WhichKey",
    event = "VeryLazy",
    enabled = true,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  { 
    "mistricky/codesnap.nvim", 
    build = "make",
  },
    {
    "ahmedkhalf/project.nvim",
    config = function()
      require("config.project").setup()
    end,
    enabled = true,
    event = "VimEnter",
    cmd = "Telescope projects",
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true
  },
  'onsails/lspkind.nvim',
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  "preservim/vim-pencil",
  {
    "sourcegraph/sg.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  'folke/zen-mode.nvim',
  'tpope/vim-obsession',
  -- Tree
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    requires = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {
        update_focused_file = {
          enable = true,
          update_cwd = false,
          ignore_list = {},
        },
        system_open = {
          cmd = nil,
          args = {},
        },
        git = {
          enable = true,
          ignore = false,
          timeout = 500,
        },
      }
    end,
  },
  -- Database
  'kristijanhusak/vim-dadbod-ui',
  'kristijanhusak/vim-dadbod-completion',
  {
    "tpope/vim-dadbod",
    opt = true,
    requires = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      require("config.dadbod").setup()
    end,
  },

  'ThePrimeagen/git-worktree.nvim',
  "tpope/vim-surround",
  'xiyaowong/nvim-transparent',
  { 
    'numToStr/FTerm.nvim',
    config = function()
    local map = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }
    require 'FTerm'.setup({
      blend = 5,
      dimensions = {
        height = 0.90,
        width = 0.90,
        x = 0.5,
        y = 0.5
      }
    })
    end
  },

  {
    'rmagatti/goto-preview',
    config = function()
      require('goto-preview').setup {
        width = 120; -- Width of the floating window
        height = 15; -- Height of the floating window
        border = {"↖", "─" ,"┐", "│", "┘", "─", "└", "│"}; -- Border characters of the floating window
        default_mappings = true;
        debug = false; -- Print debug information
        opacity = nil; -- 0-100 opacity level of the floating window where 100 is fully transparent.
        resizing_mappings = false; -- Binds arrow keys to resizing the floating window.
        post_open_hook = nil; -- A function taking two arguments, a buffer and a window to be ran as a hook.
        references = { -- Configure the telescope UI for slowing the references cycling window.
          telescope = require("telescope.themes").get_dropdown({ hide_preview = false })
        };
        -- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
        focus_on_open = true; -- Focus the floating window when opening it.
        dismiss_on_move = false; -- Dismiss the floating window when moving the cursor.
        force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
        bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
        stack_floating_preview_windows = true, -- Whether to nest floating windows
        preview_window_title = { enable = true, position = "left" }, -- Whether 
      }
    end
  },

  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  },

  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    lazy = false,
    config = function()
      require("todo-comments").setup {}
    end
  },

  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        enabled = false,
        timeout = 2000,
      })
    end
  },   

--   {
--   "folke/noice.nvim",
--   config = function()
--     require("noice").setup({
--       routes = {
--         {
--           -- This route will filter out specific known messages
--           filter = {
--             event = 'msg_show',
--             any = {
--               { find = '%d+L, %d+B' },
--               { find = '; after #%d+' },
--               { find = '; before #%d+' },
--               { find = '%d fewer lines' },
--               { find = '%d more lines' },
--               { find = 'ALE: .*' },
--               { find = 'syntax error' },
--               { find = 'linting' },
--               { find = 'Workspace loading: 0 / 0' },
--             },
--           },
--           opts = { skip = true },
--         },
--         {
--           -- This route will filter out all messages when moving the cursor
--           filter = {
--             event = 'msg_show',
--             kind = '',
--             min_count = 1,
--             find = '',
--           },
--           opts = { skip = true },
--         },
--       },
--     })
--   end,
--   dependencies = {
--     "MunifTanjim/nui.nvim",
--     "rcarriga/nvim-notify",
--   }
-- },

  
  'ray-x/go.nvim',
  'ray-x/guihua.lua',
  { "catppuccin/nvim", as = "catppuccin" },
  {
    "windwp/nvim-autopairs",
      config = function() require("nvim-autopairs").setup {} end
  },

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',
    }
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    }
  },

  { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap"} },
  'theHamsta/nvim-dap-virtual-text',
  'leoluz/nvim-dap-go',

  -- Git related plugins
  'tpope/vim-fugitive',
  'lewis6991/gitsigns.nvim',

  'nvim-lualine/lualine.nvim', -- Fancier statusline
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  'numToStr/Comment.nvim', -- "gc" to comment visual regions/lines 
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
  'nvim-telescope/telescope-symbols.nvim',
  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = vim.fn.executable 'make' == 1 },
  {
    "folke/twilight.nvim",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },
  -- LVIM
  {
    "akinsho/toggleterm.nvim",
    branch = "main",
    config = function()
      require("config.terminal").config()
      require("config.terminal").setup()
    end,
    init = function()
      require("config.terminal").init()
    end,
    cmd = {
      "ToggleTerm",
      "TermExec",
      "ToggleTermToggleAll",
      "ToggleTermSendCurrentLine",
      "ToggleTermSendVisualLines",
      "ToggleTermSendVisualSelection",
    },
    enabled = true,
  },
  { 'lukas-reineke/indent-blankline.nvim' },
  { 'mg979/vim-visual-multi' },
  { 'tpope/vim-endwise' },
  require('plugins.avante'),
  {
    "pwntester/octo.nvim",
    event = "BufRead",
  },
  { 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },
  { "ellisonleao/glow.nvim",  config = true,                         cmd = "Glow" },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = "markdown",
    config = function()
      vim.g.mkdp_auto_start = 1
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    "tpope/vim-rails",
  },
  {
    'chipsenkbeil/distant.nvim',
    branch = 'v0.3',
    config = function()
      require('distant'):setup()
    end
  },
})
