" Fuzzy file finder
Plug 'junegunn/fzf', { 'do': './install --all --no-update-rc' }
Plug 'junegunn/fzf.vim'

map <C-p> :call <SID>fzf_for_file_window()<CR>
imap <C-p> <C-o>:call <SID>fzf_for_file_window()<CR>
map <C-k> :call <SID>fzf_search_for_file_window()<CR>
imap <C-k> <C-o>:call <SID>fzf_search_for_file_window()<CR>


" Runs fzf in the 'file window'.
function! s:fzf_for_file_window()
    call ForFileWindow(':FZF')
endfunction


" Runs search in the 'file window'.
function! s:fzf_search_for_file_window()
    call ForFileWindow(':Rg')
endfunction
