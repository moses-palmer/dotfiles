" Is this a maven project?
let s:is_maven = filereadable('pom.xml')


if s:is_maven
    nnoremap <buffer> gT :call <SID>toggle_test()<cr>
endif


let s:debug_plugin = expand(glob(
\   '~/.local/lib/jdtls/plugins/com.microsoft.java.debug.plugin-*.jar'))
if filereadable(s:debug_plugin)
    " Make sure to launch the agent the first time we start debugging
    noremap <silent> <F5> :call <SID>debug()<CR>
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


" Starts the Java debug server and commences debugging.
"
" This function will restore the mapping for <F5> once the server is started.
function! s:debug()
    function! s:start_and_launch()
        function! s:on_response(data)
            if lsp#client#is_error(a:data['response'])
                echom 'Failed to start debug session: ' . string(a:data)
            else
                let s:java_debug_port = a:data['response']['result']
                echom 'Started Java debug server on port ' . s:java_debug_port
                call s:launch()
            endif
        endfunction

        " This call instructs the LSP to start the debug plugin
        call lsp#send_request('jdtls', {
        \     'method': 'workspace/executeCommand',
        \     'params': {'command': 'vscode.java.startDebugSession'},
        \     'sync': v:true,
        \     'on_notification': function('s:on_response'),
        \ })
    endfunction

    function! s:launch()
        call vimspector#LaunchWithSettings({'DAPPort': s:java_debug_port})
        nmap <F5> <Plug>VimspectorContinue
    endfunction

    if !exists('s:java_debug_port')
        call s:start_and_launch()
    else
        call s:launch()
    endif
endfunction


let s:loaded = 1
