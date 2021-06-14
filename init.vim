"Plugins
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Tools
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'neoclide/coc.nvim', {'branch': 'release'}
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'preservim/nerdtree'
Plugin 'vim-scripts/AutoComplPop'
Plugin 'w0rp/ale'

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
set complete+=kspell
set completeopt=menuone,longest
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
nmap <leader> gr <Plug>(coc-references)
nnoremap <C-p> :GFiles<CR>
nnoremap <C-b> :NERDTreeToggle<CR>
nnoremap / /\v
noremap <leader><space> :noh<cr>:call clearmatches()<cr>
nnoremap <leader><leader> <c-^>
noremap j gj
noremap k gk
nnoremap <leader>c <Plug>CommentaryLine
nnoremap <C-s> :source ~/.config/nvim/init.vim<CR>

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


