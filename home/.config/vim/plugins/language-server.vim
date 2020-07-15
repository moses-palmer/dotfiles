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

" Register language servers
let g:lsc_server_commands = {}
if executable('pyls')
    let g:lsc_server_commands.python = 'pyls'
endif
if executable('rls')
    let g:lsc_server_commands.rust = 'rustup run stable rls'
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
