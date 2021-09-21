if (has('termguicolors'))
    let g:onedark_termcolors = 256
else
    let g:onedark_termcolors = 16
endif

if g:term_has_italics
    let g:onedark_terminal_italics = 1
else
    let g:onedark_terminal_italics = 0
endif

Plug 'joshdick/onedark.vim', {'branch': 'main'}
