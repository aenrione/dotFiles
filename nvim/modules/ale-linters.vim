" ALE Linters

" Set specific linters
let g:ale_linters = {
      \ 'python': ['flake8']
      \}
let g:ale_fixers = {
      \  'ruby': ['rubocop'],
      \  'python': ['autopep8', 'autoimport'],
      \  '*': ['remove_trailing_lines', 'trim_whitespace'],
      \  'javascript': ['eslint'],
      \}

let g:airline#extensions#ale#enabled = 1 "Integration with vim-airline
" Set this variable to 1 to fix files when you save them.
let g:ale_fix_on_enter = 1
let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1
let g:ale_sign_error = '●'
let g:ale_sign_warning = '.'
let g:ale_change_sign_column_color = 1

" REMAPS
nmap <leader>an :ALENext<CR>
nmap <leader>ap :ALEPrevious<CR>
