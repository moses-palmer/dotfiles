" Fuzzy file finder
Plug 'junegunn/fzf', { 'do': './install --all --no-update-rc' }
Plug 'junegunn/fzf.vim'

" The default options passed to fzf
let g:fzf#options = [
    \ '--layout=reverse',
    \ '--info=inline']

" The default options passed to rg
let g:rg#options = [
    \ 'rg',
    \ '--column',
    \ '--line-number',
    \ '--no-heading',
    \ '--color=always',
    \ '--smart-case']

command! -bang -nargs=? -complete=dir FZFPreview
    \ call <SID>fzf(<q-args>, <bang>0)

command! -bang -nargs=* RGPreview
    \ call <SID>rg(<q-args>, <bang>0)

map <C-p> :call <SID>fzf_for_file_window()<CR>
imap <C-p> <C-o>:call <SID>fzf_for_file_window()<CR>
map <C-k> :call <SID>rg_for_file_window()<CR>
imap <C-k> <C-o>:call <SID>rg_for_file_window()<CR>


" Performs a file name search in the current directory, recursively.
function! s:fzf(query, fullscreen)
    call fzf#vim#files(
        \ a:query,
        \ fzf#vim#with_preview({'options': g:fzf#options}),
        \ a:fullscreen)
endfunction


" Performs a full search in the current directory, recursively.
function! s:rg(query, fullscreen)
    let l:rg_command_fmt = join(g:rg#options, ' ') . ' --smart-case %s || true'
    let l:initial_command = printf(l:rg_command_fmt, shellescape(a:query))

    call fzf#vim#grep(
        \ l:initial_command,
        \ 1,
        \ fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}),
        \ a:fullscreen)
endfunction


" Runs FZFPreview in the 'file window'.
function! s:fzf_for_file_window()
    call lib#for_main_window(':FZFPreview')
endfunction


" Runs RGPreview in the 'file window'.
function! s:rg_for_file_window()
    call lib#for_main_window(':RGPreview')
endfunction
