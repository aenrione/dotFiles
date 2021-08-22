"Plugins
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Tools
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'neoclide/coc.nvim', {'branch': 'release'}
Plugin 'nvim-lua/popup.nvim'
Plugin 'nvim-lua/plenary.nvim'
Plugin 'nvim-telescope/telescope.nvim'
Plugin 'nvim-telescope/telescope-fzy-native.nvim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'preservim/nerdtree'
Plugin 'w0rp/ale'
Plugin 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
Plugin 'dbeniamine/cheat.sh-vim'
Plugin 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plugin '907th/vim-auto-save'
" LSP CONFIG
Plugin 'neovim/nvim-lspconfig'
Plugin 'hrsh7th/nvim-compe'
" ColorSchemes Plugins
Plugin 'joshdick/onedark.vim'
Plugin 'morhetz/gruvbox'
" Random
Plugin 'ThePrimeagen/vim-be-good'
call vundle#end()            " required


filetype plugin indent on    " required
set nocompatible              " be iMproved, required
filetype off                  " required

filetype plugin indent on " Filetype auto-detection
syntax on " Syntax highlighting

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab " use spaces instead of tabs.
set smarttab " let's tab key insert 'tab stops', and bksp deletes tabs.
set shiftround " tab / shifting moves to closest tabstop.
set autoindent " Match indents on new lines.
set smartindent " Intellegently dedent / indent new lines based on rules.
set relativenumber
set exrc
set guicursor=
set nu
set nohlsearch
set noerrorbells
set scrolloff=40
set signcolumn=yes
set colorcolumn=80
set nobackup " We have vcs, we don't need backups.
set nowritebackup " We have vcs, we don't need backups.
set noswapfile " They're just annoying. Who likes them?
set undodir=~/.vim/undodir
set undofile
set hidden " allow me to have buffers with unsaved changes.
set autoread " when a file has changed on disk, just load it. Don't ask.
set ignorecase " case insensitive search
set smartcase " If there are uppercase letters, become case-sensitive.
set incsearch " live incremental searching
set showmatch " live match highlighting
set hlsearch " highlight matches
set gdefault " use the `g` flag by default.
set virtualedit+=block

let g:auto_save = 1  " enable AutoSave on Vim startup
" ALE Linters
" Set specific linters
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'ruby': ['rubocop'],
\   'python': ['flake8'],
\}
" Only run linters named in ale_linters settings.
let g:ale_linters_explicit = 1
let g:airline#extensions#ale#enabled = 1 "Integration with vim-airline
let g:ale_sign_column_always = 1
" Disable ALE auto highlights
let g:ale_set_highlights = 0

"Functions
fun! GotoBuffer(ctrlId)
  if (a:ctrlId > 9) || (a:ctrlId < 0)
    echo "CtrlID must be between 0-9"
    return
  end

  let contents = g:win_ctrl_buf_list[a:ctrlId]
  if type(l:contents) != v:t_list
    echo "Nothing here"
    return
  end

  let bufh = l:contents[1]
  call nvim_win_set_buf(0,l:bufh)
endfun

let g:win_ctrl_buf_list = [0,0,0,0]
fun! SetBuffer(ctrlId)
  if has_key(b:, "terminal_job_id") == 0
    echo "You must be in a terminal to execute this command."
    return
  end
  if (a:ctrlId > 9) || (a:ctrlId < 0)
    echo "CtrlID must be between 0-9"
    return
  end
  let g:win_ctrl_buf_list[a:ctrlId] = [b:terminal_job_id, nvim_win_get_buf(0)]
endfun

"Key-bindings
let mapleader = " "

" Normal-mode
noremap <leader>v <C-w>v
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap ; :
nmap <leader> gd <Plug>(coc-definition)
nmap <leader> gy <Plug>(coc-type-definition)
nmap <leader> gi <Plug>(coc-implementation)
nnoremap <C-b> :NERDTreeToggle<CR>
noremap <leader><space> :noh<cr>:call clearmatches()<cr>
nnoremap <leader><leader> <c-^>
noremap j gj
noremap k gk
nnoremap <leader>c <Plug>CommentaryLine
nnoremap <C-s> :source ~/.config/nvim/init.vim<CR>
nnoremap q <c-v>
noremap <Up>    <Nop>
noremap <Down>  <Nop>
noremap <Left>  <Nop>
noremap <Right> <Nop>

" Insert-mode
inoremap jj <esc>

" Visual-mode
vnoremap ; :
vnoremap / /\v
xnoremap K :move '<-2<CR>gv-gv
xnoremap J :move '>+1<CR>gv-gv
"Color Settings
colorscheme gruvbox
:set bg=dark
let g:airline_theme='badwolf'

" Transparent bg
:hi Normal guibg=NONE ctermbg=NONE

" Telescope Bindings

nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>
nnoremap <Leader>pf :lua require('telescope.builtin').find_files()<CR>
nnoremap <leader>pw :lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>
nnoremap <leader>pb :lua require('telescope.builtin').buffers()<CR>
nnoremap <leader>vh :lua require('telescope.builtin').help_tags()<CR>
nnoremap <leader>gw :lua require('telescope').extensions.git_worktree.git_worktrees()<CR>
nnoremap <leader>gm :lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>

" Nvim Terminal
nmap <leader>tn :terminal<CR>
nmap <leader>tu :call GotoBuffer(0)<CR>
nmap <leader>tsu :call SetBuffer(0)<CR>
"FireNvim
let g:firenvim_config = {
    \ 'globalSettings': {
        \ 'alt': 'all',
    \  },
    \ 'localSettings': {
        \ '.*': {
            \ 'cmdline': 'neovim',
            \ 'content': 'text',
            \ 'priority': 0,
            \ 'selector': 'textarea:not([readonly]), div[role="textbox"]',
            \ 'takeover': 'never',
        \ },
    \ }
\ }
au BufEnter github.com_*.txt set filetype=markdown

" Fugitive
nmap <leader>gs :G<CR>
nmap <leader>g2 :diffget //3<CR>
nmap <leader>g1 :diffget // <CR>
nmap <leader>g3 :Git -c push.default=current push<CR>

" LSP config (the mappings used in the default file don't quite work right)
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> <C-n> <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> <C-p> <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

" auto-format
autocmd BufWritePre *.js lua vim.lsp.buf.formatting_sync(nil, 100)
autocmd BufWritePre *.jsx lua vim.lsp.buf.formatting_sync(nil, 100)
autocmd BufWritePre *.py lua vim.lsp.buf.formatting_sync(nil, 100)

" LSP
lua require('lspconfig').solargraph.setup{}
lua require('lspconfig').pyright.setup{}
lua require("lspconfig").tsserver.setup{}
lua require('lspconfig').bashls.setup{}
lua require('lspconfig').html.setup{}
lua require("lspconfig").vuels.setup{}
lua require("lspconfig").cssls.setup{}

" Files
luafile ~/.config/nvim/lua/plugins/compe-config.lua

