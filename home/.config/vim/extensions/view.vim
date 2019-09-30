" Highlight the current row and allow toggling of column highlight
set cursorline
nnoremap <Leader>C :set cursorcolumn!<CR>


" Move between splits using shift+alt+arrow
map <S-C-Left> :wincmd h<CR>
map! <S-C-Left> <C-o>:wincmd h<CR>
tnoremap <S-C-Left> <C-w>h
map <S-C-Down> :wincmd j<CR>
map! <S-C-Down> <C-o>:wincmd j<CR>
tnoremap <S-C-Down> <C-w>j
map <S-C-Up> :wincmd k<CR>
map! <S-C-Up> <C-o>:wincmd k<CR>
tnoremap <S-C-Up> <C-w>k
map <S-C-Right> :wincmd l<CR>
map! <S-C-Right> <C-o>:wincmd l<CR>
tnoremap <S-C-Right> <C-w>l


" Display line numbers
set number
set numberwidth=4


" Display a ruler at column 80
set colorcolumn=80
set textwidth=79


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
