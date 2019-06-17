" Enable the language server
Plugin 'prabirshrestha/asyncomplete.vim'
Plugin 'prabirshrestha/asyncomplete-lsp.vim'
Plugin 'prabirshrestha/async.vim'
Plugin 'prabirshrestha/vim-lsp'

let g:lsp_signs_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1

nmap gd :LspDefinition<CR>
nmap <leader>gd :LspHover<CR>
nmap gr :LspReferences<CR>
nmap rr :LspRename<CR>
nmap ff :LspWorkspaceSymbol<CR>

nmap <F3> :call ToggleQuickfixWindow()<CR>
imap <F3> <C-o>:call ToggleQuickfixWindow()<CR>

nmap <M-Up> :cprev<CR>
imap <M-Up> <C-o>:cprev<CR>
nmap <M-Down> :cnext<CR>
imap <M-Down> <C-o>:cnext<CR>

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"

" Toggle the quick fix window.
function! ToggleQuickfixWindow()
    for window in getwininfo()
        if window.quickfix == 1
            " Close the quick fix window
            execute window.winnr . 'wincmd w'
            execute 'wincmd c'

            " Reselect the editor window
            execute GetEditorWindow() . 'wincmd w'
            return
        endif
    endfor

    LspDocumentDiagnostics
endfunction

" Enable language server for Python
if executable('pyls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif

" Enable language server for Rust
if executable('rls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'rls',
        \ 'cmd': {server_info->['rustup', 'run', 'stable', 'rls']},
        \ 'whitelist': ['rust'],
        \ })
endif
