" Map leader to which_key
nnoremap <silent> <leader> :silent WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :silent <c-u> :silent WhichKeyVisual '<Space>'<CR>

" Create map to add keys to
let g:which_key_map =  {}
" Define a separator
let g:which_key_sep = '→'

" By default timeoutlen is 1000 ms
set timeoutlen=500


" Not a fan of floating windows for this
let g:which_key_use_floating_win = 0

" Change the colors if you want
highlight default link WhichKey          Operator
highlight default link WhichKeySeperator DiffAdded
highlight default link WhichKeyGroup     Identifier
highlight default link WhichKeyDesc      Function

" Hide status line
autocmd! FileType which_key
autocmd  FileType which_key set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler

" Single mappings
let g:which_key_map['/'] = [ '<Plug>NERDCommenterToggle'  , 'comment' ]
let g:which_key_map['e'] = [ ':NERDTreeToggle'            , 'explorer' ]
let g:which_key_map['f'] = [ ':Files'                     , 'search files' ]
let g:which_key_map['h'] = [ '<C-W>s'                     , 'split below']
let g:which_key_map['S'] = [ ':Startify'                  , 'start screen' ]
let g:which_key_map['T'] = [ ':Rg'                        , 'search text' ]
let g:which_key_map['v'] = [ '<C-W>v'                     , 'split right']
let g:which_key_map['z'] = [ ':Goyo'                      , 'zen' ]
let g:which_key_map['<Tab>'] = [ ':bnext'                 , 'next buffer' ]
let g:which_key_map['<S-Tab>'] = [ ':bprevious'          , 'previous buffer' ]

" a for ale-linters
let g:which_key_map.a = {
      \ 'name' : '+ale-linters' ,
      \ 'n' : [':ALENext'         , 'history'],
      \ 'p' : [':ALEPrevious'     , 'commands'],
      \ }

" b for buffers
let g:which_key_map.b = {
      \ 'name' : '+buffers' ,
      \ 'g' : [':buffers<CR>:buffer<Space>'  , 'go to'],
      \ 'd' : [':buffers<CR>:bdelete<Space>' , 'delete'],
      \ 'c' : [':Bclose'                     , 'close current'],
      \ 'f' : ['bfirst'                      , 'first-buffer']    ,
      \ 'h' : ['Startify'                    , 'home-buffer']     ,
      \ 'l' : ['blast'                       , 'last-buffer']     ,
      \ 'n' : ['bnext'                       , 'next-buffer']     ,
      \ 'p' : ['bprevious'                   , 'previous-buffer'] ,
      \ '?' : ['Buffers'                     , 'fzf-buffer']      ,
      \ }

" g for git
let g:which_key_map.g = {
      \ 'name' : '+git' ,
      \ }

" s is for search
let g:which_key_map.s = {
      \ 'name' : '+search' ,
      \ '/' : [':History/'     , 'history'],
      \ ';' : [':Commands'     , 'commands'],
      \ 'a' : [':Ag'           , 'text Ag'],
      \ 'b' : [':BLines'       , 'current buffer'],
      \ 'B' : [':Buffers'      , 'open buffers'],
      \ 'c' : [':Commits'      , 'commits'],
      \ 'C' : [':BCommits'     , 'buffer commits'],
      \ 'f' : [':Files'        , 'files'],
      \ 'g' : [':GFiles'       , 'git files'],
      \ 'G' : [':GFiles?'      , 'modified git files'],
      \ 'h' : [':History'      , 'file history'],
      \ 'H' : [':History:'     , 'command history'],
      \ 'l' : [':Lines'        , 'lines'] ,
      \ 'm' : [':Marks'        , 'marks'] ,
      \ 'M' : [':Maps'         , 'normal maps'] ,
      \ 'p' : [':Helptags'     , 'help tags'] ,
      \ 'P' : [':Tags'         , 'project tags'],
      \ 's' : [':Snippets'     , 'snippets'],
      \ 'S' : [':Colors'       , 'color schemes'],
      \ 't' : [':Rg'           , 'text Rg'],
      \ 'T' : [':BTags'        , 'buffer tags'],
      \ 'w' : [':Windows'      , 'search windows'],
      \ 'y' : [':Filetypes'    , 'file types'],
      \ 'z' : [':FZF'          , 'FZF'],
      \ }

" Register which key map
call which_key#register('<Space>', "g:which_key_map")
