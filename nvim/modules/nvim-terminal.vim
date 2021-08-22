" Nvim Terminal
nmap <leader>tn :terminal<CR>
nmap <leader>tu :call GotoBuffer(0)<CR>
nmap <leader>tsu :call SetBuffer(0)<CR>

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

