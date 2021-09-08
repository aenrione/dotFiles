"Plugins
set rtp+=~/.vim/bundle/Vundle.vim
call plug#begin('~/.vim/plugged')

" Tools
Plug 'VundleVim/Vundle.vim'
Plug 'tpope/vim-fugitive'
Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
" Plugin 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'w0rp/ale'
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
Plug 'dbeniamine/cheat.sh-vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug '907th/vim-auto-save'
Plug 'liuchengxu/vim-which-key'
Plug 'ryanoasis/vim-devicons'
Plug 'justinmk/vim-sneak'
Plug 'her/synicons.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-startify'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'dyng/ctrlsf.vim'

" LSP CONFIG
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'

" ColorSchemes Plugins
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'

" Random
Plug 'ThePrimeagen/vim-be-good'
call plug#end()

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

" Fold Config
set foldmethod=indent
set foldlevel=99
set foldclose=all
" zo - opens folds
" zc - closes fold
" zm - increases auto fold depth
" zr - reduces auto fold depth

" AutoSave
let g:auto_save = 1  " enable AutoSave on Vim startup

"Color Settings
colorscheme gruvbox
:set bg=dark
let g:airline_theme='badwolf'

" Transparent bg
:hi Normal guibg=NONE ctermbg=NONE

" Devicons
set encoding=UTF-8

" Sneak
let g:sneak#label = 1

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#buffer_nr_show = 1

" NERDTree
let NERDTreeShowHidden=1

" Highlight Yank
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}
augroup END

" CtrlLSF
let g:ctrlsf_backend = 'ack'
