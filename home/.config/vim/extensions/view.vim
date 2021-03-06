" Highlight the current row and allow toggling of column highlight
set cursorline
nnoremap <Leader>C :set cursorcolumn!<CR>


" Display cursor position
set ruler


" Scroll instead of wrap
set nowrap
set sidescroll=1
set listchars=extends:>,precedes:<
set sidescrolloff=2


" Scroll using arrow keys
map <S-Down> <C-E>
map <S-Up> <C-Y>


" Display a ruler at column 80 and line numbers to the left
set colorcolumn=80
set textwidth=79
set number


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
        colorscheme seagrey-dark
    else
        colorscheme noctu
    endif
catch /^Vim\%((\a\+)\)\=:E185/
    " Ignore
endtry
