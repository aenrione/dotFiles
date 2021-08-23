"Key-bindings
let mapleader = " "

" Normal-mode
noremap <leader>v <C-w>v
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap ; :
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

" Coc
nmap gd <Plug>(coc-definition)
nmap <leader> gy <Plug>(coc-type-definition)
nmap <leader> gi <Plug>(coc-implementation)

" Telescope Bindings
nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
nnoremap <leader>pp :lua require('telescope.builtin').git_files()<CR>
nnoremap <Leader>pf :lua require('telescope.builtin').find_files()<CR>
nnoremap <leader>pw :lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>
nnoremap <leader>pb :lua require('telescope.builtin').buffers()<CR>
nnoremap <leader>vh :lua require('telescope.builtin').help_tags()<CR>
nnoremap <leader>gw :lua require('telescope').extensions.git_worktree.git_worktrees()<CR>
nnoremap <leader>gm :lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>

" Fugitive
nmap <leader>gs :G<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gf :diffget //3<CR>
nmap <leader>gj :diffget // <CR>
nmap <leader>g1 :Git -c push.default=current push<CR>

" Buffer Control
nnoremap <silent><leader><tab> <Cmd>bnext<CR>
nnoremap <silent><leader><s-tab> <Cmd>bprevious<CR>
nnoremap <silent><leader>1 <Cmd>b1<CR>
nnoremap <silent><leader>2 <Cmd>b2<CR>
nnoremap <silent><leader>3 <Cmd>b3<CR>
nnoremap <silent><leader>4 <Cmd>b4<CR>
nnoremap <silent><leader>5 <Cmd>b5<CR>
nnoremap <silent><leader>6 <Cmd>b6<CR>
nnoremap <silent><leader>7 <Cmd>b7<CR>
nnoremap <silent><leader>8 <Cmd>b8<CR>
nnoremap <silent><leader>9 <Cmd>b9<CR>
