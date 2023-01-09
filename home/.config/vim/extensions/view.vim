" Highlight the current row and allow toggling of column highlight
set cursorline
nnoremap <Leader>C :set cursorcolumn!<CR>


" Display cursor position
set ruler

" Use fullsized fillchars for separators
set fillchars+=vert:│
set fillchars+=stl:―
set fillchars+=stlnc:―


" Scroll instead of wrap
set nowrap
set sidescroll=1
set listchars=extends:>,precedes:<
set sidescrolloff=2


" Scroll using arrow keys
map <S-Down> <C-E>
imap <S-Down> <C-O><C-E>
map <S-Up> <C-Y>
imap <S-Up> <C-O><C-Y>


" Display a ruler at column 80
set colorcolumn=80
set textwidth=79


" Always display the sign column
set signcolumn=yes


" Let the preview window open at the bottom
set splitbelow


" Ensure the background is correctly handled in tmux
set t_ut=


" Enable mouse
set mouse=a


" Load theme
try
    if (has('termguicolors'))
        set termguicolors
        colorscheme onedark
        highlight ColorColumn guibg=#353535
    else
        colorscheme noctu
    endif
catch /^Vim\%((\a\+)\)\=:E185/
    " Ignore
endtry


" Reverse buftabline highlight groups
highlight! link BufTabLineActive TabLineSel
highlight! link BufTabLineCurrent PmenuSel


" Send current window to sides
noremap <leader>h <C-w>H
noremap <leader>j <C-w>J
noremap <leader>k <C-w>K
noremap <leader>l <C-w>L
