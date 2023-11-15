" Fuzzy file finder
Plug 'junegunn/fzf', { 'do': './install --all --no-update-rc' }
Plug 'junegunn/fzf.vim'


map <C-p> :call <SID>fzf_for_file_window()<CR>
imap <C-p> <C-o>:call <SID>fzf_for_file_window()<CR>
map <leader><C-p> :call <SID>fzf_for_file_window_git_dirty()<CR>
map <C-k> :call <SID>rg_for_file_window()<CR>
imap <C-k> <C-o>:call <SID>rg_for_file_window()<CR>


" Runs FZF in the 'file window'.
function! s:fzf_for_file_window()
    call lib#for_main_window(':FZF')
endfunction


" Runs FZF in the 'file window' for dirty git files.
function! s:fzf_for_file_window_git_dirty()
    try
        let l:fzf_default_command = $FZF_DEFAULT_COMMAND
        let $FZF_DEFAULT_COMMAND = 'git diff --name-only'
        call s:fzf_for_file_window()
    finally
        let $FZF_DEFAULT_COMMAND = l:fzf_default_command
    endtry
endfunction


" Runs RGPreview in the 'file window'.
function! s:rg_for_file_window()
    call lib#for_main_window(':call ' . expand('<SID>') . 'rg()')
endfunction

function! s:rg()
    call fzf#vim#grep(
    \   $FZF_SEARCH_COMMAND . ' -- ""',
    \   1,
    \   fzf#vim#with_preview())
endfunction
