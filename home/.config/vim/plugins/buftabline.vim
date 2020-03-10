" Display buffers in the tab line
Plug 'ap/vim-buftabline'

nnoremap <M-Left> :call <SID>previous_buffer()<CR>
nnoremap <M-Right> :call <SID>next_buffer()<CR>
imap <M-Left> <C-o>:call <SID>previous_buffer()<CR>
imap <M-Right> <C-o>:call <SID>next_buffer()<CR>


" Selects the next buffer in the 'file window'.
function! s:next_buffer()
    call ForFileWindow(':bnext')
endfunction


" Selects the previous buffer in the 'file window'.
function! s:previous_buffer()
    call ForFileWindow(':bprevious')
endfunction
