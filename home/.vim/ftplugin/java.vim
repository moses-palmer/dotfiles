" Is this a maven project?
let s:is_maven = filereadable('pom.xml')


if s:is_maven
    nnoremap <buffer> gT :call <SID>toggle_test()<cr>
endif


if exists('s:loaded')
    finish
endif


" Toggles between a class and its test suite.
function! s:toggle_test()
    let l:is_test = expand('%:p') =~ 'src/test/java/.*Test\.java$'
    let l:is_main = expand('%:p') =~ 'src/main/java/.*\.java$'
    if l:is_test && !l:is_main
        execute(':e ' . substitute(
        \     substitute(expand('%:p'), 'Test\.java$', '.java', 'g'),
        \     'src/test/java',
        \     'src/main/java',
        \     'g'))
    elseif !l:is_test && l:is_main
        execute(':e ' . substitute(
        \     substitute(expand('%:p'), '\.java$', 'Test.java', 'g'),
        \     'src/main/java',
        \     'src/test/java',
        \     'g'))
    endif
endfunction


let s:loaded = 1
