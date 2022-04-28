" Let :W save with sudo
command! W :call <sid>write_sudo()


" Attempts to write the current buffer with elevated privileges.
function! s:write_sudo()
    silent write !sudo tee % > /dev/null
    if v:shell_error == 0
        edit!
    endif
endfunction
