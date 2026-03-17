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
      ["9"] = {
        name = "99",
        v = { "<cmd>lua require('99').visual()<cr>", "99 Visual" },
        s = { "<cmd>lua require('99').stop_all_requests()<cr>", "99 Stop" },
      },
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
      ["C"] = { "<cmd>b#|bd#<CR>", "Close Buffer" },
      ["c{"] = { "<cmd>ConflictChooseOurs<cr>", "Conflict: Choose Ours" },
      ["c}"] = { "<cmd>ConflictChooseTheirs<cr>", "Conflict: Choose Theirs" },
      ["cp"] = { "<cmd>ConflictPrev<cr>", "Conflict: Prev" },
      ["cn"] = { "<cmd>ConflictNext<cr>", "Conflict: Next" },
      ["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
      ["e"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" },
      ["O"] = { "<cmd>Octo<CR>", "Octo git" },
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
        g = { "<cmd>lua require('telescope.builtin').git_status({ previewer = false })<cr>", "Git Status (no preview)" },
        G = { "<cmd>Telescope git_status<cr>", "Git Status" },
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

  local function get_visual_selection()
    vim.cmd([[normal! "vy]])
    return vim.fn.getreg("v")
  end

  local config = M.config()
  which_key.setup(config.setup)

  local opts = config.opts
  local vopts = config.vopts
   
  config.mappings["g"]["d"] = { "<cmd>DiffviewOpen<CR>", "DiffView" }
  config.mappings["g"]["D"] = { "<cmd>DiffviewClose<CR>", "DiffView Close" }
  config.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
  config.mappings["B"] = { "<cmd>Telescope buffers<CR>", "Buffers" }
  config.mappings["t"] = { "<cmd>ToggleLineNumbers<CR>", "Toggle Lines" }
  config.mappings["Q"] = { "<cmd>qa!<CR>", "Quit all (force)" }
  config.mappings["g"]["B"] = { "<cmd>!gh browse<CR><CR>", "Open origin" }
  config.mappings["b"]["C"] = { "<cmd>%bd<CR><CR>", "Close all buffers" }
  config.vmappings["s"] = {
    name = "Search",
    t = {
      function()
        local selection = get_visual_selection()
        if selection ~= "" then
          require("telescope.builtin").grep_string { search = selection }
        end
      end,
      "Text (selection)",
    },
  }
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

  -- OpenCode ask (visual)
  config.vmappings["o"] = {
    name = "OpenCode",
    a = { ":OpenCodeAsk<cr>", "Ask (prompt modal)" },
    f = { ":OpenCodeFill<cr>", "Fill (no prompt)" },
    c = { ":OpenCodeChat<cr>", "Chat (toggle)" },
    o = { ":OpenCodeChatOpen<cr>", "Chat (open)" },
    x = { ":OpenCodeChatClose<cr>", "Chat (close)" },
  }

  -- Octo.nvim
  config.mappings["o"] = {
    name = "OpenCode/Octo",
    a = { ":OpenCodeAsk<cr>", "Ask (prompt modal)" },
    f = { ":OpenCodeFill<cr>", "Fill (no prompt)" },
    c = { ":OpenCodeChat<cr>", "Chat (toggle)" },
    o = { ":OpenCodeChatOpen<cr>", "Chat (open)" },
    x = { ":OpenCodeChatClose<cr>", "Chat (close)" },
    G = { "<cmd>Octo<cr>", "Octo" },
    i = { "<cmd>Octo issue list<cr>", "List GitHub Issues" },
    p = { "<cmd>Octo pr list<cr>", "List GitHub PullRequests" },
    d = { "<cmd>Octo discussion list<cr>", "List GitHub Discussions" },
    n = { "<cmd>Octo notification list<cr>", "List GitHub Notifications" },
    s = {
      function()
        require("octo.utils").create_base_search_command { include_current_repo = true }
      end,
      "Search GitHub",
    },
  -- Linear
  config.mappings["M"] = {
    name = "Linear",
    m = { "<cmd>lua require('linear-nvim').show_assigned_issues()<cr>", "My Issues" },
    t = { "<cmd>lua require('linear-nvim').show_issues_by_team()<cr>", "Issues by Team" },
    p = { "<cmd>lua require('linear-nvim').show_issues_by_project()<cr>", "Issues by Project" },
    l = { "<cmd>lua require('linear-nvim').show_issues_by_label()<cr>", "Issues by Label" },
    y = { "<cmd>lua require('linear-nvim').show_cycle_issues()<cr>", "Current Cycle" },
    f = { "<cmd>lua require('linear-nvim').search_issues()<cr>", "Search Issues" },
    c = { "<cmd>lua require('linear-nvim').create_issue()<cr>", "Create Issue" },
    s = { "<cmd>lua require('linear-nvim').show_issue_details()<cr>", "Show Issue (cursor)" },
    R = { "<cmd>lua require('linear-nvim').refresh_cache()<cr>", "Refresh Cache" },
    -- Custom Views
    v = { "<cmd>lua require('linear-nvim').show_custom_views()<cr>", "Custom Views" },
    V = { "<cmd>lua require('linear-nvim').show_pinned_views()<cr>", "Pinned Views" },
    a = { "<cmd>lua require('linear-nvim').pin_view()<cr>", "Pin a View" },
    d = { "<cmd>lua require('linear-nvim').remove_pinned_view()<cr>", "Unpin View" },
  }
  config.vmappings["M"] = {
    name = "Linear",
    c = { "<cmd>lua require('linear-nvim').create_issue()<cr>", "Create Issue" },
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
