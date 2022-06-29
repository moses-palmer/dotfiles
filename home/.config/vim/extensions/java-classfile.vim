" Automatically decompile a Java class file when opened
augroup java_decompile
    autocmd!
    autocmd BufReadCmd *.class call <SID>decompile()
augroup END


" Decompiles the current buffer and replaces it with Java source.
function! s:decompile()
    silent %!java-decompile %
    if v:shell_error == 0
        set filetype=java
        setlocal readonly
        setlocal nomodified
        0
    endif
endfunction
