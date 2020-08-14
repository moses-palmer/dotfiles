packadd termdebug

" Use a vertical split
let g:termdebug_wide = 1

" Set and clear breakpoints
noremap <leader>b :Break<CR>
noremap <leader>c :Clear<CR>

" Control execution
noremap <F5> :call <SID>start_debugger()<CR>
noremap <C-F5> :call <SID>launch_application()<CR>
noremap <F6> :Continue<CR>
noremap <F7> :Step<CR>
noremap <F8> :Over<CR>


" Launches a debugger.
"
" If the global variable g:debugger#binary exists, it is used as binary name,
" otherwise a name is requested.
function! s:start_debugger()
    call s:build(0)

    if exists('g:debugger#binary')
        let l:name = g:debugger#binary
    else
        call inputsave()
        let l:name = input('Enter name: ')
        call inputrestore()
    endif
    execute ':Termdebug ' . l:name
endfunction


" Launches the project application.
"
" If the global variable d:debugger#launch_command exists, it is used,
" otherwise a command is requested.
function! s:launch_application()
    call s:build(1)

    if exists('g:debugger#launch_command')
        let l:command = g:debugger#launch_command
    else
        call inputsave()
        let l:command = input('Enter command: ')
        call inputrestore()
    endif
    execute '! ' . l:command
endfunction


" Runs the build command
function s:build(silent)
    if exists('g:debugger#build_command')
        if a:silent
            call system(g:debugger#build_command)
        else
            execute '! ' . g:debugger#build_command
        endif
    endif
endfunction
