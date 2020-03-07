execute('source ' . expand('<sfile>:p:h') . '/app.vim')

" We set this to have :Man open in the main window
set ft=man

" Set options appropriate for man pages
set colorcolumn=0
set noexpandtab
set nolist
set nomodifiable
set nonumber
set readonly
set shiftwidth=8
set softtabstop=8
set tabstop=8

" Load the built-in plugin, and let us use it for K
source $VIMRUNTIME/ftplugin/man.vim
set keywordprg=:Man

nnoremap <2-LeftMouse> :execute(':Man ' . expand('<cword>'))<CR>

" Ensure no plugin autocmds are used on startup
autocmd! VimEnter *
