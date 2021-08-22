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
