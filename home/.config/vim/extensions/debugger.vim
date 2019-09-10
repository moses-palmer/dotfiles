packadd termdebug

" Use a vertical split
let g:termdebug_wide = 1


" Launches a debugger.
"
" If the global variable g:debug_binary exists, it is used as binary name,
" otherwise a name is requested.
function! StartDebugger()
    if exists('g:debug_binary')
        let l:name = g:debug_binary
    else
        call inputsave()
        let l:name = input('Enter name: ')
        call inputrestore()
    endif
    execute ':Termdebug ' . l:name
endfunction


" Set and clear breakpoints
noremap <leader>b :Break<CR>
noremap <leader>c :Clear<CR>

" Control execution
noremap <F5> :call StartDebugger()<CR>
noremap <F6> :Continue<CR>
noremap <F7> :Step<CR>
noremap <F8> :Over<CR>
