--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "gruvbox"
lvim.transparent_window = true

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
-- }

-- Use which-key to add extra bindings with the leader-key prefix
-- import my nvim remaps
vim.cmd([[
  nnoremap <silent><tab> <Cmd>bnext<CR>
  nnoremap <silent><s-tab> <Cmd>bprevious<CR>
  noremap <Up>    <Nop>
  noremap <Down>  <Nop>
  noremap <Left>  <Nop>
  noremap <Right> <Nop>

nnoremap Y y$

nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z
" Insert mode movement
imap <M-h> <left>
imap <M-j> <down>
imap <M-k> <up>
imap <M-l> <right>
imap <M-f> <C-right>
imap <M-b> <C-left>

nnoremap L <Cmd>bnext<CR>
nnoremap H <Cmd>bprevious<CR>
:set nohlsearch
]])
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["t"] = { "<cmd>ToggleTerm<CR>", "Terminal" }
lvim.builtin.which_key.mappings["a"] = {
  name = "Arduino",
  a = { "<cmd>ArduinoAttach<cr>", "Automatically attach to your board" },
  b = { "<cmd>ArduinoChooseBoard<cr>", "Select the board" },
  p = { "<cmd>ArduinoChooseProgrammer<cr>", "Select the programmer" },
  s = { "<cmd>ArduinoChoosePort<cr>", "Choose Port" },
  v = { "<cmd>ArduinoVerify<cr>", "Build sketch" },
  u = { "<cmd>ArduinoUpload<cr>", "Upload" },
  c = { "<cmd>ArduinoSerial<cr>", "Connect to the board for debugging over a serial port." },
  x = { "<cmd>ArduinoUploadAndSerial<cr>", "Build, upload, and connect for debugging." },
  i = { "<cmd>ArduinoInfo<cr>", "Display internal information" },
}

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- ---@usage disable automatic installation of servers
lvim.lsp.automatic_servers_installation = false

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
-- ---see the full default list `:lua print(vim.inspect(lvim.lsp.automatic_configuration.skipped_servers))`
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "volar, tailwindcss" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skiipped for the current filetype
-- vim.tbl_map(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "autopep8", filetypes = { "python" } },
  -- { command = "rubocop",  filetypes = { "ruby" } },
  -- { command = "rufo",     filetypes = { "ruby" } },
  { command = "prettier", filetypes = { "vue" } },
  -- { command = "eslint", filetypes = { "eruby", "html", "html.erb", "html-erb" } },
  --   {
  --     -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
  --     command = "prettier",
  --     ---@usage arguments to pass to the formatter
  --     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
  --     extra_args = { "--print-with", "100" },
  --     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
  --     filetypes = { "typescript", "typescriptreact" },
  --   },
}

-- -- set additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "flake8",  filetypes = { "python" } },
  { command = "eslint",  filetypes = { "vue", "eruby", "html", "html.erb" } },
  { command = "rubocop", filetypes = { "ruby" } }
  --   {
  --     -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
  --     command = "shellcheck",
  --     ---@usage arguments to pass to the formatter
  --     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
  --     extra_args = { "--severity", "warning" },
  --   },
  --   {
  --     command = "codespell",
  --     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
  --     filetypes = { "javascript", "python" },
  --   },
}

-- Additional Plugins
lvim.plugins = {
  { 'stevearc/vim-arduino' },
  {
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup({
        input = { enabled = false },
      })
    end,
  },
  { 'lukas-reineke/indent-blankline.nvim' },
  { 'mg979/vim-visual-multi' },
  { 'tpope/vim-endwise' },
  { 'morhetz/gruvbox' },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup()
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    }
  },
  {
    "github/copilot.vim",
    -- event = "VeryLazy",
    config = function()
      -- copilot assume mapped
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_no_tab_map = true
    end,
  },
  {
    "hrsh7th/cmp-copilot",
    config = function()
      lvim.builtin.cmp.formatting.source_names["copilot"] = "( )"
      table.insert(lvim.builtin.cmp.sources, 2, { name = "copilot" })
    end,
  },
  -- { 'chrisbra/Colorizer' },
  {
    "pwntester/octo.nvim",
    event = "BufRead",
  },
  { 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  {
    "epwalsh/obsidian.nvim",
    config = function()
      require("obsidian").setup({
        event = {
          "BufReadPre /home/aenrione/Documents/Obsidian Vault/**.md",
          "BufNewFile /home/aenrione/Documents/Obsidian Vault/**.md",
        },
        dependencies = {
          -- Required.
          "nvim-lua/plenary.nvim",

        },
        dir = "~/Documents/Obsidian Vault", -- no need to call 'vim.fn.expand' here
        completion = {
          -- If using nvim-cmp, otherwise set to false
          nvim_cmp = true,
          -- Trigger completion at 2 chars
          min_chars = 2,
          -- Where to put new notes created from completion. Valid options are
          --  * "current_dir" - put new notes in same directory as the current buffer.
          --  * "notes_subdir" - put new notes in the default notes subdirectory.
          new_notes_location = "current_dir",

          -- Whether to add the output of the node_id_func to new notes in autocompletion.
          -- E.g. "[[Foo" completes to "[[foo|Foo]]" assuming "foo" is the ID of the note.
          prepend_note_id = true
        },
      })
    end,
    completion = {
      -- If using nvim-cmp, otherwise set to false
      nvim_cmp = true,
      -- Trigger completion at 2 chars
      min_chars = 2,
      -- Where to put new notes created from completion. Valid options are
      --  * "current_dir" - put new notes in same directory as the current buffer.
      --  * "notes_subdir" - put new notes in the default notes subdirectory.
      new_notes_location = "current_dir",

      -- Whether to add the output of the node_id_func to new notes in autocompletion.
      -- E.g. "[[Foo" completes to "[[foo|Foo]]" assuming "foo" is the ID of the note.
      prepend_note_id = true
    },
  }
}

-- additional options
vim.opt.relativenumber = true
vim.opt.mouse = "n"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.colorcolumn = "80"


-- Autocommands (https://neovim.io/doc/user/autocmd.html)
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = { "*" },
  -- enable wrap mode for json files only
  command = ":normal zz",
})
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { "*" },
--   -- enable wrap mode for json files only
--   -- command = ":ColorHighlight",
-- })
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })
