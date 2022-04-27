Plug 'puremourning/vimspector'

" Set and display breakpoints
nmap <leader>b <plug>VimspectorToggleBreakpoint
nmap <leader>B <plug>VimspectorBreakpoints

" Control execution
noremap <leader><F5> :VimspectorReset<CR>
nmap <F5> <Plug>VimspectorContinue
nmap <S-F5> <Plug>VimspectorRunToCursor
nmap <F7> <Plug>VimspectorStepInto
nmap <S-F7> <Plug>VimspectorStepOut
nmap <F8> <Plug>VimspectorStepOver
nmap <F10> <Plug>VimspectorReset

nmap <leader><Up> <Plug>VimspectorUpFrame
nmap <leader><Down> <Plug>VimspectorDownFrame
nmap <leader>K <Plug>VimspectorBalloonEval
