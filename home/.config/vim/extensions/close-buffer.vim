" Let \q close buffers, but not windows
command! KillBuffer call KillBuffer(1)
map <leader>q <Plug>KillBuffer
nnoremap <silent> <Plug>KillBuffer :<C-u>KillBuffer<CR>
