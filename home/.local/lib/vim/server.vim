" Starts the server and creates the command pipe.
"
" A cleanup handler will be registered
function server#start(command_pipe)
    call system('mkfifo ' . shellescape(a:command_pipe))
    let s:server_job = job_start(['tail', '-f', a:command_pipe], {
    \   'out_cb': expand('<SID>') . 'on_command'})
    let s:command_pipe = a:command_pipe

    augroup Server
        autocmd VimLeave * call <SID>stop()<cr>
    augroup END
endfunction


" The function called when a message is read from the command pipe.
"
" It will simply execute the string.
function s:on_command(channel, msg)
    execute a:msg
endfunction


" Cleans up the server by stopping the job and removing the command pipe.
function s:stop()
    call job_stop(s:server_job)
    call system('rm ' . shellescape(s:command_pipe))
endfunction
