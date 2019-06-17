" File tree with git status
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'

let NERDTreeIgnore = [
    \ '\.egg-info$',
    \ '\.pyc$',
    \ '^__pycache__$',
    \ '\.rs.bk$'
    \ ]
let g:NERDTreeIndicatorMapCustom = {
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

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

map <C-h> :NERDTreeFind<cr>
imap <C-h> <C-o>:NERDTreeFind<cr>
map <C-t> :NERDTreeToggle<CR>

function! s:CloseIfOnlyControlWinLeft()
  if winnr("$") != 1
    return
  endif
  if (exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1)
        \ || &buftype == 'quickfix'
    q
  endif
endfunction

augroup CloseIfOnlyControlWinLeft
  au!
  au BufEnter * call s:CloseIfOnlyControlWinLeft()
augroup END
