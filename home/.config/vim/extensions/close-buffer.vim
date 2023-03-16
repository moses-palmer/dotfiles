" Let \q and \w close buffers, but not windows
command! KillBufferMoveLeft
    \ call lib#for_main_window('call lib#kill_current_buffer(-1)')
command! KillBufferMoveRight
    \ call lib#for_main_window('call lib#kill_current_buffer(1)')
command! KillLeft
    \ call lib#for_main_window('call lib#kill_other_buffers(-1)')
command! KillRight
    \ call lib#for_main_window('call lib#kill_other_buffers(1)')

map <silent> <leader>q :KillBufferMoveLeft<CR>
map <silent> <leader>Q :KillLeft<CR>
map <silent> <leader>w :KillBufferMoveRight<CR>
map <silent> <leader>W :KillRight<CR>
