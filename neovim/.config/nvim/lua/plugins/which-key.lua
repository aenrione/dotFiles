local M = {}
M.config = function()
  local which_key_config = {
    active = true,
    on_config_done = nil,
    setup = {
      plugins = {
        marks = false,
        registers = false,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = false,
          motions = false,
          text_objects = false,
          windows = false,
          nav = false,
          z = false,
          g = false,
        },
      },
      operators = { gc = "Comments" },
      key_labels = {},
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
      popup_mappings = {
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
      },
      window = {
        border = "single",
        position = "bottom",
        margin = { 1, 0, 1, 0 },
        padding = { 2, 2, 2, 2 },
        winblend = 0,
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "left",
      },
      ignore_missing = true,
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
      show_help = true,
      show_keys = true,
      triggers = "auto",
      triggers_blacklist = {
        i = { "j", "k" },
        v = { "j", "k" },
      },
      disable = {
        buftypes = {},
        filetypes = { "TelescopePrompt" },
      },
    },

    opts = {
      mode = "n",
      prefix = "<leader>",
      buffer = nil,
      silent = true,
      noremap = true,
      nowait = true,
    },
    vopts = {
      mode = "v",
      prefix = "<leader>",
      buffer = nil,
      silent = true,
      noremap = true,
      nowait = true,
    },
    vmappings = {
      ["/"] = { "<Plug>(comment_toggle_linewise_visual)", "Comment toggle linewise (visual)" },
      l = {
        name = "LSP",
        a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
      },
      g = {
        name = "Git",
        r = { "<cmd>Gitsigns reset_hunk<cr>", "Reset Hunk" },
        s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage Hunk" },
      },
    },
    mappings = {
      ["f"] = { "<cmd>Telescope find_files hidden=true<cr>", "Find File" },
      ["P"] = { "<cmd>Telescope projects<cr>", "Projects" },
      ["r"] = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
      ["t"] = { "<cmd>ToggleTerm<CR>", "Terminal" },
      [";"] = { "<cmd>Alpha<CR>", "Dashboard" },
      ["w"] = { "<cmd>w!<CR>", "Save" },
      ["q"] = { "<cmd>confirm q<CR>", "Quit" },
      ["/"] = { "<Plug>(comment_toggle_linewise_current)", "Comment toggle current line" },
      ["c"] = { "<cmd>b#|bd#<CR>", "Close Buffer" },
      ["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
      ["e"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" },
      b = {
        name = "Buffers",
        j = { "<cmd>BufferLinePick<cr>", "Jump" },
        f = { "<cmd>Telescope buffers previewer=false<cr>", "Find" },
        b = { "<cmd>BufferLineCyclePrev<cr>", "Previous" },
        n = { "<cmd>BufferLineCycleNext<cr>", "Next" },
        W = { "<cmd>noautocmd w<cr>", "Save without formatting (noautocmd)" },
        c = { "<cmd>b#|bd#<CR>", "Close Buffer in split" },
        e = {
          "<cmd>BufferLinePickClose<cr>",
          "Pick which buffer to close",
        },
        h = { "<cmd>BufferLineCloseLeft<cr>", "Close all to the left" },
        l = {
          "<cmd>BufferLineCloseRight<cr>",
          "Close all to the right",
        },
        D = {
          "<cmd>BufferLineSortByDirectory<cr>",
          "Sort by directory",
        },
        L = {
          "<cmd>BufferLineSortByExtension<cr>",
          "Sort by language",
        },
      },
      d = {
        name = "Debug",
        t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
        b = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
        c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
        C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
        d = { "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect" },
        g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
        i = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into" },
        o = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over" },
        u = { "<cmd>lua require'dap'.step_out()<cr>", "Step Out" },
        p = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
        r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
        s = { "<cmd>lua require'dap'.continue()<cr>", "Start" },
        q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
        U = { "<cmd>lua require'dapui'.toggle({reset = true})<cr>", "Toggle UI" },
      },
      p = {
        name = "Plugins",
        i = { "<cmd>Lazy install<cr>", "Install" },
        s = { "<cmd>Lazy sync<cr>", "Sync" },
        S = { "<cmd>Lazy clear<cr>", "Status" },
        c = { "<cmd>Lazy clean<cr>", "Clean" },
        u = { "<cmd>Lazy update<cr>", "Update" },
        p = { "<cmd>Lazy profile<cr>", "Profile" },
        l = { "<cmd>Lazy log<cr>", "Log" },
        d = { "<cmd>Lazy debug<cr>", "Debug" },
      },
      g = {
        name = "Git",
        g = { "<cmd>lua require 'config.terminal'.lazygit_toggle()<cr>", "Lazygit" },
        n = { "<cmd>Neogit<cr>", "Neogit" },
        j = { "<cmd>lua require 'gitsigns'.nav_hunk('next', {navigation_message = false})<cr>", "Next Hunk" },
        k = { "<cmd>lua require 'gitsigns'.nav_hunk('prev', {navigation_message = false})<cr>", "Prev Hunk" },
        l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
        L = { "<cmd>lua require 'gitsigns'.blame_line({full=true})<cr>", "Blame Line (full)" },
        p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
        r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
        R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
        s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
        u = {
          "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
          "Undo Stage Hunk",
        },
        o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
        b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
        C = {
          "<cmd>Telescope git_bcommits<cr>",
          "Checkout commit(for current file)",
        },
        d = {
          "<cmd>Gitsigns diffthis HEAD<cr>",
          "Git Diff",
        },
      },
      l = {
        name = "LSP",
        a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
        d = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics" },
        w = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
        i = { "<cmd>LspInfo<cr>", "Info" },
        f = { "<cmd>ALEFix<cr>", "Fix" },
        I = { "<cmd>Mason<cr>", "Mason Info" },
        j = {
          "<cmd>lua vim.diagnostic.goto_next()<cr>",
          "Next Diagnostic",
        },
        k = {
          "<cmd>lua vim.diagnostic.goto_prev()<cr>",
          "Prev Diagnostic",
        },
        l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
        q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
        r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
        s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
        S = {
          "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
          "Workspace Symbols",
        },
        e = { "<cmd>Telescope quickfix<cr>", "Telescope Quickfix" },
      },
      L = {
        name = "+Neovim",
        c = {
          "<cmd>edit " .. vim.fn.stdpath('config') .. "/init.lua<cr>",
          "Edit config.lua",
        },
        f = { "<cmd>LocalNvimConfig<CR>", "Local nvim files" },
        r = { "<cmd>luafile ~/.config/nvim/init.lua<cr>", "Reload config" },
        L = {
          name = "+logs",
          d = {
            "view default log",
          },
          D = {
            "Open the default logfile",
          },
          l = {
            "view lsp log",
          },
          L = { "<cmd>lua vim.fn.execute('edit ' .. vim.lsp.get_log_path())<cr>", "Open the LSP logfile" },
          n = {
            "view neovim log",
          },
          N = { "<cmd>edit $NVIM_LOG_FILE<cr>", "Open the Neovim logfile" },
        },
      },
      s = {
        name = "Search",
        b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
        f = { "<cmd>Telescope find_files<cr>", "Find File" },
        h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
        H = { "<cmd>Telescope highlights<cr>", "Find highlight groups" },
        M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
        r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
        R = { "<cmd>Telescope registers<cr>", "Registers" },
        t = { "<cmd>Telescope live_grep<cr>", "Text" },
        k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
        C = { "<cmd>Telescope commands<cr>", "Commands" },
        l = { "<cmd>Telescope resume<cr>", "Resume last search" },
        p = {
          "<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>",
          "Colorscheme with Preview",
        },
      },
      T = {
        name = "Treesitter",
        i = { ":TSConfigInfo<cr>", "Info" },
      },
    },
  }

  return which_key_config
end



M.setup = function()
  local which_key = require "which-key"

  local config = M.config()
  which_key.setup(config.setup)

  local opts = config.opts
  local vopts = config.vopts
   
  config.mappings["g"]["d"] = { "<cmd>DiffviewOpen<CR>", "DiffView" }
  config.mappings["g"]["D"] = { "<cmd>DiffviewClose<CR>", "DiffView Close" }
  config.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
  config.mappings["B"] = { "<cmd>Telescope buffers<CR>", "Buffers" }
  config.mappings["t"] = { "<cmd>ToggleLineNumbers<CR>", "Toggle Lines" }
  config.mappings["g"]["B"] = { "<cmd>!gh browse<CR><CR>", "Open origin" }
  config.mappings["b"]["C"] = { "<cmd>%bd<CR><CR>", "Close all buffers" }
  config.mappings["m"] = {
    name = "Markdown",
    b = { "<cmd>MarkdownPreview<cr>", "Preview in browser" },
    c = { "<cmd>Glow<cr>", "Preview in terminal" },
  }
-- config.mappings["M"] = { function() require("harpoon.mark").add_file() end, "Harpoon add" }
  config.mappings["A"] = {
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

  -- Rails module
  config.mappings["r"] = {
    name = "Rails",
    m = { "<cmd>RailsModels<CR>", "Models" },
    c = { "<cmd>RailsControllers<CR>", "Controllers" },
    g = { "<cmd>RailsMigrations<CR>", "Migrations" },
    h = { "<cmd>RailsHelpers<CR>", "Helpers" },
    M = { "<cmd>SearchMicroserviceModels<CR>", "Microservice Models" },
    s = { "<cmd>RailsSerializers<CR>", "Serializers" },
    j = { "<cmd>RailsJavascript<CR>", "Javascript" },
    v = { "<cmd>RailsViews<CR>", "Views" },
    V = { "<cmd>SearchMicroserviceViews<CR>", "Microservice Views" },
    C = { "<cmd>SearchMicroserviceControllers<CR>", "Microservice Controllers" },
    G = { "<cmd>SearchMicroserviceMigrations<CR>", "Microservice Migrations" },
    H = { "<cmd>SearchMicroserviceHelpers<CR>", "Microservice Helpers" },
    S = { "<cmd>SearchMicroserviceSerializers<CR>", "Microservice Serializers" },
  }

  -- ChatGPT.nvim
  -- Create vimwhichkeys
  config.mappings["C"] = {
    name = "ChatGPT",
    c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
    C = { "<cmd>ChatGPT<CR>", "ChatGPT" },
    a = { "<cmd>ChatGPTActAs<CR>", "Act as" },
  }

  -- folke/todo
  config.mappings["T"] = {
    name = "Todo",
    t = { "<cmd>TodoTelescope<CR>", "Search" },
    f = { "<cmd>TodoTrouble<CR>", "Trouble" },
    l = { "<cmd>TodoLocList<CR>", "LocList" },
    q = { "<cmd>TodoQuickFix<CR>", "QuickFix" },
    n = { "<cmd>TodoNext<CR>", "Next" },
    p = { "<cmd>TodoPrev<CR>", "Prev" },
  }


  local mappings = config.mappings
  local vmappings = config.vmappings

  which_key.register(mappings, opts)
  which_key.register(vmappings, vopts)

  if config.on_config_done then
    config.on_config_done(which_key)
  end
end

return M
