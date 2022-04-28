if has('terminal') && executable('inotifywait')
    command! -nargs=* Watch :call <sid>watch(expand('%'), <q-args>)
endif


" Watches a path, executing a command with the path appended each time it is
" modified.
function! s:watch(path, command)
    execute('term ++shell ++rows=4 '
        \ . 'while inotifywait --event delete_self ' . a:path . '; '
        \ . 'do ' . a:command . ' ' . a:path . '; done')
    wincmd p
endfunction
