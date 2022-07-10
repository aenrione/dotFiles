"Plugins
set rtp+=~/.vim/bundle/Vundle.vim
call plug#begin('~/.vim/plugged')

" Tools
Plug 'VundleVim/Vundle.vim'
Plug 'tpope/vim-fugitive'
Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
Plug 'neoclide/coc.nvim', {'branch': 'release'}
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
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug '907th/vim-auto-save'
Plug 'liuchengxu/vim-which-key'
Plug 'ryanoasis/vim-devicons'
Plug 'her/synicons.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-startify'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'dyng/ctrlsf.vim'
Plug 'vimwiki/vimwiki'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'ap/vim-css-color'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'kassio/neoterm'
Plug 'xianzhon/vim-code-runner'
Plug 'SirVer/ultisnips'
Plug 'mlaursen/vim-react-snippets'
Plug 'honza/vim-snippets'



" LSP CONFIG
" Plug 'neovim/nvim-lspconfig'
" Plug 'williamboman/nvim-lsp-installer'
" Plug 'hrsh7th/nvim-compe'

" ColorSchemes Plugins
Plug 'morhetz/gruvbox'

call plug#end()

set nocompatible              " be iMproved, required
filetype off                  " required

filetype plugin indent on " Filetype auto-detection
syntax on " Syntax highlighting
filetype plugin on

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab
set shiftround
set autoindent
set smartindent
set relativenumber
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
\,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
\,sm:block-blinkwait175-blinkoff150-blinkon175
set nu
set nohlsearch
set noerrorbells
set scrolloff=40
set signcolumn=yes
set colorcolumn=80
set undodir=~/.vim/undodir
set undofile
set autoread
set incsearch
set virtualedit+=block
set autowrite

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

" NeoTerm
let g:neoterm_default_mod='belowright' " open terminal in bottom split
let g:neoterm_size=16 " terminal split size
let g:neoterm_autoscroll=1 " scroll to the bottom when running a command

"Ultisnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
