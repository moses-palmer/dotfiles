" Executes a command for the presumed 'file window'.
"
" The file window is the largest window.
function! ForFileWindow(command)
    let l:winnr = GetEditorWindow()
    if winnr > -1
        let current = winnr()
        execute winnr . 'wincmd w'
        try
            execute a:command
        finally
            execute current . 'wincmd w'
        endtry
    endif
endfunction


" Returns the editor window ID.
"
" The editor window is the largest window.
function! GetEditorWindow()
    let l:acc = 0
    let l:winnr = -1
    for window in getwininfo()
        let curr = window.width * window.height
        if curr > acc
            let l:acc = curr
            let l:winnr = window.winnr
        endif
    endfor

    return l:winnr
endfunction


" Deletes a buffer.
"
" Windows are kept. If no buffers remain, create a scratch buffer.
function! KillBuffer(stage)
    if (a:stage == 1)
        if (!buflisted(winbufnr(0)))
            bd!
            return
        endif
        let s:KillBufferBufNum = bufnr("%")
        let s:KillBufferWinNum = winnr()
        windo call KillBuffer(2)
        execute s:KillBufferWinNum . 'wincmd w'
        let s:buflistedLeft = 0
        let s:bufFinalJump = 0
        let l:nBufs = bufnr("$")
        let l:i = 1
        while(l:i <= l:nBufs)
            if (l:i != s:KillBufferBufNum)
                if (buflisted(l:i))
                    let s:buflistedLeft = s:buflistedLeft + 1
                else
                    if (bufexists(l:i) && !strlen(bufname(l:i))
                                \ && !s:bufFinalJump)
                        let s:bufFinalJump = l:i
                    endif
                endif
            endif
            let l:i = l:i + 1
        endwhile
        if (!s:buflistedLeft)
            if (s:bufFinalJump)
                windo if (buflisted(winbufnr(0)))
                            \ | execute "b! " . s:bufFinalJump | endif
            else
                enew
                let l:newBuf = bufnr("%")
                windo if (buflisted(winbufnr(0)))
                            \ | execute "b! " . l:newBuf | endif
            endif
            execute s:KillBufferWinNum . 'wincmd w'
        endif
        if (buflisted(s:KillBufferBufNum) || s:KillBufferBufNum == bufnr("%"))
            execute "bd! " . s:KillBufferBufNum
        endif
        if (!s:buflistedLeft)
            set buflisted
            set bufhidden=delete
            set buftype=
            setlocal noswapfile
        endif
    else
        if (bufnr("%") == s:KillBufferBufNum)
            let prevbufvar = bufnr("#")
            if (prevbufvar > 0 && buflisted(prevbufvar)
                        \ && prevbufvar != s:KillBufferBufNum)
                b #
            else
                bn
            endif
        endif
    endif
endfunction


" Executes a shell command and opens the output in a new scratch buffer.
"
" The command is run in the directory containing the current open file.
function! RunShellCommand(cmdline, syntax)
    let l:expanded_cmdline = a:cmdline
    for l:part in split(a:cmdline, ' ')
        if part[0] =~ '\v[%#<]'
            let l:expanded_part = fnameescape(expand(part))
            let l:expanded_cmdline = substitute(
                \ l:expanded_cmdline,
                \ l:part,
                \ l:expanded_part,
                \ '')
        endif
    endfor

    belowright vnew
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    execute '0read !'.l:expanded_cmdline
    execute 'set syntax='.a:syntax
    setlocal nomodifiable
endfunction
