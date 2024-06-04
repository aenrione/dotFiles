vim.api.nvim_set_keymap("i", "jj", "<Esc>", {noremap=false})
-- twilight
vim.api.nvim_set_keymap("n", "tw", ":Twilight<enter>", {noremap=false})
-- buffers
vim.api.nvim_set_keymap("n", "tk", ":blast<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "tj", ":bfirst<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "th", ":bprev<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "tl", ":bnext<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "td", ":bdelete<enter>", {noremap=false})
-- files
vim.api.nvim_set_keymap("n", "QQ", ":q!<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "WW", ":w!<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "E", "$", {noremap=false})
vim.api.nvim_set_keymap("n", "B", "^", {noremap=false})
vim.api.nvim_set_keymap("n", "TT", ":TransparentToggle<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "ss", ":noh<CR>", {noremap=true})
--
-- splits
--
vim.api.nvim_set_keymap("n", "<C-W>,", ":vertical resize -10<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<C-W>.", ":vertical resize +10<CR>", {noremap=true})
vim.keymap.set('n', '<space><space>', "<cmd>set nohlsearch<CR>")
-- Quicker close split
vim.keymap.set("n", "<leader>qq", ":q<CR>",
  {silent = true, noremap = true}
)

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Noice
vim.api.nvim_set_keymap("n", "<leader>nn", ":Noice dismiss<CR>", {noremap=true})

vim.keymap.set("n", "<leader>ee", "<cmd>GoIfErr<cr>",
  {silent = true, noremap = true}
)


-- Import from LVIM
-- -- MOVE Keymappings
vim.keymap.set('n', '<tab>', '<Cmd>bnext<CR>', { silent = true })
vim.keymap.set('n', '<s-tab>', '<Cmd>bprevious<CR>', { silent = true })
vim.keymap.set('n', 'L', '<Cmd>bnext<CR>', { silent = true })
vim.keymap.set('n', 'H', '<Cmd>bprevious<CR>', { silent = true })
vim.keymap.set('n', 'Y', 'y$', { silent = true })
vim.keymap.set('n', 'n', 'nzzzv', { silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { silent = true })
vim.keymap.set('n', 'J', 'mzJ`z', { silent = true })
vim.keymap.set('i', '<M-h>', '<left>', { silent = true })
vim.keymap.set('i', '<M-j>', '<down>', { silent = true })
vim.keymap.set('i', '<M-k>', '<up>', { silent = true })
vim.keymap.set('i', '<M-l>', '<right>', { silent = true })
vim.keymap.set('i', '<M-f>', '<C-right>', { silent = true })
vim.keymap.set('i', '<M-b>', '<C-left>', { silent = true })
vim.keymap.set('n', '<M-p>', '"0p', { silent = true })
vim.keymap.set('n', '<M-o>', 'o<Esc>', { silent = true })

vim.keymap.set('n', '<M-p>', '"0p', { silent = true })
vim.keymap.set('n', '<M-o>', 'o<Esc>', { silent = true })

-- setup quit
vim.keymap.set('n', '<C-q>', '<Cmd>q!<CR>', { silent = true })

vim.keymap.set('n', '<C-c>', '<cmd>:ChatGPT<CR>', { silent = true })
vim.keymap.set('v', '<C-i>', '<cmd>:ChatGPTEditWithInstructions<CR>', { silent = true })
-- vim.keymap.set('v', '<C-u>', '<cmd>:ChatGPTCompleteCode<CR>', { silent = true })
vim.keymap.set('v', '<C-y>', '<cmd>:ChatGPTRunOptions<CR>', { silent = true })

vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- You can also specify a list of valid jump keywords

vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next({ keywords = { "ERROR", "WARNING" } })
end, { desc = "Next error/warning todo comment" })

vim.api.nvim_set_keymap("i", "<C-l>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-g>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.api.nvim_set_keymap("n", "<C-g>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

