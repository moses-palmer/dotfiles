Plug 'tpope/vim-fugitive'

command! Log Git log
    \ --patch
    \ --decorate
    \ %
