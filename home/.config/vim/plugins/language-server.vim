" Enable the language server
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_document_code_action_signs_hint = {'text': '‼'}
let g:lsp_format_sync_timeout = 1000


set foldmethod=expr
\   foldexpr=lsp#ui#vim#folding#foldexpr()
\   foldtext=lsp#ui#vim#folding#foldtext()


function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    nmap <buffer> ga <plug>(lsp-code-action-float)
    nmap <buffer> gA <plug>(lsp-code-lens)
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> <leader>d <plug>(lsp-peek-definition)
    nmap <buffer> gH <plug>(lsp-call-hierarchy-incoming)
    nmap <buffer> <leader>H <plug>(lsp-call-hierarchy-outgoing)
    nmap <buffer> gI <plug>(lsp-implementation)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> K <plug>(lsp-hover)
    nmap <buffer> <leader>K :LspHover --ui=preview<CR>
    nmap <buffer> <M-Down> <plug>(lsp-next-diagnostic)
    nmap <buffer> <M-Up> <plug>(lsp-previous-diagnostic)
    nmap <buffer> rr <plug>(lsp-rename)
    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

    nmap <F3> :call <SID>all_diagnostics()<CR>
    imap <F3> <C-o>:call <SID>all_diagnostics()<CR>

    " Allow mouse navigation; make sure to press the left button to change
    " cursor position before going to definition
    nmap <C-LeftMouse> <LeftMouse><plug>(lsp-definition)
    imap <C-LeftMouse> <LeftMouse><C-o><plug>(lsp-definition)
endfunction


if filereadable(expand('~/.local/lib/jdtls/bin/jdtls'))
    let s:java_debug_plugin = expand(glob(
    \     '~/.local/lib/jdtls/plugins/com.microsoft.java.debug.plugin-*.jar'))
    au User lsp_setup
    \ call lsp#register_server({
    \   'name': 'jdtls',
    \   'cmd': {server_info->['jdtls']},
    \   'allowlist': ['java'],
    \   'initialization_options': filereadable(s:java_debug_plugin)
    \       ? { 'bundles': [s:java_debug_plugin] }
    \       : {},
    \ }) |
    \ call lsp#register_command(
    \   'java.apply.workspaceEdit',
    \   function('s:java_apply_workspaceEdit'))
    autocmd FileType java setlocal omnifunc=lsp#complete

    function! s:java_apply_workspaceEdit(context)
        let l:command = get(a:context, 'command', {})
        call lsp#utils#workspace_edit#apply_workspace_edit(
        \   l:command['arguments'][0])
    endfunction
endif

if executable('typescript-language-server')
    au User lsp_setup call lsp#register_server({
    \   'name': 'typescript-language-server',
    \   'cmd': {server_info->['typescript-language-server', '--stdio']},
    \   'allowlist': ['javascript', 'typescript'],
    \ })
    autocmd! FileType javascript setlocal omnifunc=lsp#complete
    autocmd! FileType typescript setlocal omnifunc=lsp#complete
endif

if executable('pyls')
    au User lsp_setup call lsp#register_server({
    \   'name': 'pylsp',
    \   'cmd': {server_info->['pylsp']},
    \   'allowlist': ['python'],
    \ })
    autocmd FileType python setlocal omnifunc=lsp#complete
endif

if executable('rust-analyzer')
    au User lsp_setup
    \ call lsp#register_server({
    \   'name': 'rust-analyzer',
    \   'cmd': {server_info->['rust-analyzer']},
    \   'allowlist': ['rust'] }) |
    \ call lsp#register_command(
    \   'rust-analyzer.applySourceChange',
    \   function('s:rust_applySourceChange'))
    autocmd! FileType rust setlocal omnifunc=lsp#complete
    autocmd! BufWritePre *.rs call execute('LspDocumentFormatSync')

    function! s:rust_applySourceChange(context)
        let l:command = get(
        \   a:context, 'command', {})
        let l:workspace_edit = get(
        \   l:command['arguments'][0], 'workspaceEdit', {})
        if !empty(l:workspace_edit)
            call lsp#utils#workspace_edit#apply_workspace_edit(l:workspace_edit)
        endif

        let l:cursor_position = get(
        \   l:command['arguments'][0], 'cursorPosition', {})
        if !empty(l:cursor_position)
            call cursor(lsp#utils#position#lsp_to_vim('%', l:cursor_position))
        endif
    endfunction
endif


function! s:all_diagnostics()
    if s:toggle_quickfix_window()
        LspDocumentDiagnostics
    endif
endfunction


" Toggles the quickfix window and returns whether is is visible.
function! s:toggle_quickfix_window()
    for l:window in getwininfo()
        if l:window.quickfix == 1
            " Close the quick fix window
            execute l:window.winnr . 'wincmd w'
            execute 'wincmd c'

            " Reselect the editor window
            execute lib#main_window() . 'wincmd w'
            return 0
        endif
    endfor

    return 1
endfunction


augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
