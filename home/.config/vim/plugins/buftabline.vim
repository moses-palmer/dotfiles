" Display buffers in the tab line
Plug 'ap/vim-buftabline'

" Selects the next buffer in the 'file window'.
function! NextBuffer()
    call ForFileWindow(':bnext')
endfunction

" Selects the previous buffer in the 'file window'.
function! PreviousBuffer()
    call ForFileWindow(':bprevious')
endfunction

nnoremap <M-Left> :call PreviousBuffer()<CR>
nnoremap <M-Right> :call NextBuffer()<CR>
imap <M-Left> <C-o>:call PreviousBuffer()<CR>
imap <M-Right> <C-o>:call NextBuffer()<CR>
