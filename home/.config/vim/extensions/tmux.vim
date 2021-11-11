" Move between splits and tmux panes using shift+alt+arrow
map <silent> <S-C-Left> :TmuxLeft<CR>
map! <silent> <S-C-Left> <C-o>:TmuxLeft<CR>
tnoremap <silent> <S-C-Left> <C-w>h
map <silent> <S-C-Down> :TmuxDown<CR>
map! <silent> <S-C-Down> <C-o>:TmuxDown<CR>
tnoremap <silent> <S-C-Down> <C-w>j
map <silent> <S-C-Up> :TmuxUp<CR>
map! <silent> <S-C-Up> <C-o>:TmuxUp<CR>
tnoremap <silent> <S-C-Up> <C-w>k
map <silent> <S-C-Right> :TmuxRight<CR>
map! <silent> <S-C-Right> <C-o>:TmuxRight<CR>
tnoremap <silent> <S-C-Right> <C-w>l

noremap <leader>y :TmuxCopyText<CR>
noremap <leader>p :TmuxCopyPath<CR>

command! TmuxLeft call <SID>navigate('h')
command! TmuxDown call <SID>navigate('j')
command! TmuxUp call <SID>navigate('k')
command! TmuxRight call <SID>navigate('l')
command! -range TmuxCopyText call <SID>tmux_copy_text()
command! TmuxCopyPath call <SID>tmux_copy_path()


" Performs a tmux aware window navigation.
"
" If the movement is out from an edge window, the navigation is passed onto
" tmux, which switches panes.
function! s:navigate(dir)
    " Get the current winnr, move and check if the navigation command had any
    " effect
    let l:winnr = winnr()
    execute 'wincmd ' . a:dir
    let l:at_edge = (l:winnr == winnr())

    " If it did not, pass the movement on to tmux after translating movement
    " characters
    if l:at_edge
        let l:args = 'select-pane -t '
            \ . shellescape($TMUX_PANE) . ' -'
            \ . tr(
                \ a:dir,
                \ 'hjkl',
                \ 'LDUR')
        silent call s:tmux(l:args)
    endif
endfunction


function! s:tmux_copy_text()
    try
        let l:a_save = @a
        silent normal! gv"ay
        call s:tmux_copy(@a)
        echo 'Copied selection to tmux clipboard'
    finally
        let @a = l:a_save
    endtry
endfunction


function! s:tmux_copy_path()
    let l:s = expand('%:p')
    call s:tmux_copy(s)
    echo 'Copied path to tmux clipboard'
endfunction


" Copies a string to the tmux clipboard.
function! s:tmux_copy(string)
    silent call s:tmux('set-buffer ' . shellescape(a:string))
endfunction


" Sends a tmux command over the tmux socket.
function! s:tmux(args)
    let l:socket = split($TMUX, ',')[0]
    return system('tmux -S ' . l:socket . ' ' . a:args)
endfunction
