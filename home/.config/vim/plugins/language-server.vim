" Enable the language server
Plug 'natebosch/vim-lsc'

let g:lsc_auto_map = {
    \ 'GoToDefinition': 'gd',
    \ 'GoToDefinitionSplit': '<leader>gd',
    \ 'FindReferences': 'gr',
    \ 'FindImplementations': 'gI',
    \ 'FindCodeActions': 'ga',
    \ 'Rename': 'rr',
    \ 'ShowHover': v:true,
    \ 'DocumentSymbol': 'go',
    \ 'WorkspaceSymbol': 'gS',
    \ 'SignatureHelp': 'gm',
    \ 'Completion': 'completefunc',
    \}

" Close the preview window with documentation automatically
autocmd CompleteDone * silent! pclose

nmap <M-Up> :cprev<CR>
imap <M-Up> <C-o>:cprev<CR>
nmap <M-Down> :cnext<CR>
imap <M-Down> <C-o>:cnext<CR>
nmap <F3> :call <SID>all_diagnostics()<CR>
imap <F3> <C-o>:call <SID>all_diagnostics()<CR>

" Allow mouse navigation; make sure to press the left button to change cursor
" position before going to definition
nmap <C-LeftMouse> <LeftMouse>:LSClientGoToDefinition<CR>
imap <C-LeftMouse> <LeftMouse><C-o>:LSClientGoToDefinition<CR>
nmap <M-C-LeftMouse> <LeftMouse>:LSClientGoToDefinitionSplit<CR>
imap <M-C-LeftMouse> <LeftMouse><C-o>:LSClientGoToDefinitionSplit<CR>

" Register language servers
let g:lsc_server_commands = {}
if executable('typescript-language-server')
    let g:lsc_server_commands.javascript = 'typescript-language-server --stdio'
endif
if executable('pyls')
    let g:lsc_server_commands.python = 'pyls'
endif
if executable('rust-analyzer')
    let g:lsc_server_commands.rust = 'rust-analyzer'
endif


function! s:all_diagnostics()
    if s:toggle_quickfix_window()
        LSClientAllDiagnostics
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
            execute lib#editor_window() . 'wincmd w'
            return 0
        endif
    endfor

    return 1
endfunction
