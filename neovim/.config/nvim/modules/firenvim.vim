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

