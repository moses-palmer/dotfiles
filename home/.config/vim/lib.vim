" Executes a command in a window.
function! lib#for_window(winnr, command)
    let l:current = getwininfo(winnr())
    execute a:winnr . 'wincmd w'
    try
        execute a:command
    finally
        if !empty(l:current)
            execute win_id2win(l:current[0].winid) . 'wincmd w'
        endif
    endtry
endfunction


" Executes a command for the main window.
"
" If an editor window exists, that is used, otherwise the largest window is
" used.
function! lib#for_main_window(command)
    call lib#for_window(lib#main_window(), a:command)
endfunction


" The winnr of the main window.
"
" If the current window is an editor window, it is returned, otherwise the
" largest window is returned.
function! lib#main_window()
    if lib#is_editor_window(winnr())
        return winnr()
    else
        let l:acc = 0
        let l:winnr = -1
        for l:window in getwininfo()
            let l:curr = l:window.width * l:window.height
            if l:curr > l:acc
                let l:acc = l:curr
                let l:winnr = l:window.winnr
            endif
        endfor

        return l:winnr
    endif
endfunction


" Determines whether a window is an editor window.
"
" An editor window is a window where the &buftype is not 'help', 'nofile' or
" 'quickfix'.
function! lib#is_editor_window(winnr)
    let l:buftype = getwinvar(a:winnr, '&buftype')
    return !(l:buftype == 'quickfix'
        \ || l:buftype == 'help'
        \ || l:buftype == 'nofile')
endfunction


" Kills the current buffer in the editor window.
"
" If possible, the sibling buffer in the direction dir is activated, otherwise
" the other direction is attempted. If no other listed buffers are found, a
" scratch buffer is created to keep the window from closing.
function! lib#kill_current_buffer(dir)
    " Find the current buffer for the editor window
    let l:bufnr = winbufnr(lib#main_window())

    " Ensure the buffer is not modified
    if getbufvar(l:bufnr, '&mod')
        echo('The current buffer is modified')
        return
    end

    " Find the buffer to switch to; prefer the direction specified
    let l:next_bufnr = s:bufsib(l:bufnr, a:dir)
    if l:next_bufnr == 0
        let l:next_bufnr = s:bufsib(l:bufnr, -a:dir)
    endif

    " Switch to the next buffer, or create a new scratch buffer if none was
    " found
    if l:next_bufnr > 0
        execute 'b! ' . l:next_bufnr
    else
        execute 'enew'
        set buflisted
        set bufhidden=delete
        set buftype=
        setlocal noswapfile
    endif

    " Finally delete the current buffer
    execute(l:bufnr . 'bd')
endfunction


" Kills all other buffers in the editor window in the direction dir.
function! lib#kill_other_buffers(dir)
    " While we have siblings in the direction specify, kill all unmodified
    " buffers
    let l:bufnr = s:bufsib(winbufnr(lib#main_window()), a:dir)
    while l:bufnr > 0
        if !getbufvar(l:bufnr, '&mod')
            execute(l:bufnr . 'bd')
        endif
        let l:bufnr = s:bufsib(l:bufnr, a:dir)
    endwhile
endfunction


" Finds the closest listed buffer from the buffer with number nr, going in the
" direction dir.
"
" If no listed buffers are found in the direction specified, 0 is returned.
function! s:bufsib(nr, dir)
    let l:min = 1
    let l:max = bufnr('$')

    let l:result = a:nr + a:dir
    while !buflisted(l:result)
        if l:result < l:min || l:result > l:max
            return 0
        else
            let l:result = l:result + a:dir
        endif
    endwhile

    return l:result
endfunction
