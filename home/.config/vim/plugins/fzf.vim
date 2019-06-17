" Fuzzy file finder
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

" Runs fzf in the 'file window'.
function! FZFForFileWindow()
    call ForFileWindow(':FZF')
endfunction

" Runs search in the 'file window'.
function! FZFSearchForFileWindow()
    call ForFileWindow(':Rg')
endfunction

map <C-p> :call FZFForFileWindow()<CR>
imap <C-p> <C-o>:call FZFForFileWindow()<CR>
map <C-k> :call FZFSearchForFileWindow()<CR>
imap <C-k> <C-o>:call FZFSearchForFileWindow()<CR>
