" Let \q and \w close buffers, but not windows
command! KillBufferMoveLeft
    \ call lib#for_editor_window('call lib#kill_current_buffer(-1)')
command! KillBufferMoveRight
    \ call lib#for_editor_window('call lib#kill_current_buffer(1)')
command! KillLeft
    \ call lib#for_editor_window('call lib#kill_other_buffers(-1)')
command! KillRight
    \ call lib#for_editor_window('call lib#kill_other_buffers(1)')

map <leader>q :KillBufferMoveLeft<CR>
map <leader>Q :KillLeft<CR>
map <leader>w :KillBufferMoveRight<CR>
map <leader>W :KillRight<CR>
