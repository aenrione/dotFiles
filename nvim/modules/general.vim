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
Plugin 'liuchengxu/vim-which-key'
Plugin 'ryanoasis/vim-devicons'
Plugin 'justinmk/vim-sneak'
Plugin 'her/synicons.vim'
Plugin 'mhinz/vim-startify'

" Bufferline
Plugin 'kyazdani42/nvim-web-devicons' " Recommended (for coloured icons)
Plugin 'akinsho/bufferline.nvim'

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
