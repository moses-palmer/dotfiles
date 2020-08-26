" File tree with git status
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

let NERDTreeIgnore = [
    \ '\.egg-info$',
    \ '\.pyc$',
    \ '^__pycache__$',
    \ '\.rs.bk$'
    \ ]
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ "Modified"  : "•",
    \ "Staged"    : "✚",
    \ "Untracked" : "◦",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "•",
    \ "Clean"     : "✔︎",
    \ "Ignored"   : '☒',
    \ "Unknown"   : "?"
    \ }

augroup NERDTree
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 0 && !exists("s:std_in")
        \ | NERDTree | execute 'wincmd l'| endif
augroup END

map <C-h> :NERDTreeFind<cr>
imap <C-h> <C-o>:NERDTreeFind<cr>
map <C-t> :NERDTreeToggle<CR>

function! s:close_if_only_control_win_left()
    if winnr('$') != 1
        return
    endif
    if (exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1)
            \ || &buftype == 'quickfix'
        q
    endif
endfunction

augroup close_if_only_control_win_left
  au!
  au BufEnter * call s:close_if_only_control_win_left()
augroup END
