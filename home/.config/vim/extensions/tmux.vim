" Move between splits and tmux panes using shift+alt+arrow
map <S-C-Left> :TmuxLeft<CR>
map! <S-C-Left> <C-o>:TmuxLeft<CR>
tnoremap <S-C-Left> <C-w>h
map <S-C-Down> :TmuxDown<CR>
map! <S-C-Down> <C-o>:TmuxDown<CR>
tnoremap <S-C-Down> <C-w>j
map <S-C-Up> :TmuxUp<CR>
map! <S-C-Up> <C-o>:TmuxUp<CR>
tnoremap <S-C-Up> <C-w>k
map <S-C-Right> :TmuxRight<CR>
map! <S-C-Right> <C-o>:TmuxRight<CR>
tnoremap <S-C-Right> <C-w>l

command! TmuxLeft call <SID>navigate('h')
command! TmuxDown call <SID>navigate('j')
command! TmuxUp call <SID>navigate('k')
command! TmuxRight call <SID>navigate('l')


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


" Sends a tmux command over the tmux socket.
function! s:tmux(args)
    let l:socket = split($TMUX, ',')[0]
    return system('tmux -S ' . l:socket . ' ' . a:args)
endfunction
