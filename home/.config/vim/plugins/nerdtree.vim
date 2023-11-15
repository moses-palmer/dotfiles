" File tree with git status
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

let g:NERDTreeBookmarksFile = '~/.config/NERDTreeBookmarks'
let g:NERDTreeIgnore = [
    \ '\.egg-info$',
    \ '\.pyc$',
    \ '^__pycache__$',
    \ '\.rs.bk$'
    \ ]
let g:NERDTreeGitStatusConcealBrackets = 1
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified'  : '•',
    \ 'Staged'    : '✚',
    \ 'Untracked' : '◦',
    \ 'Renamed'   : '➜',
    \ 'Unmerged'  : '═',
    \ 'Deleted'   : '✖',
    \ 'Dirty'     : '•',
    \ 'Clean'     : '✔︎',
    \ 'Ignored'   : '☒',
    \ 'Unknown'   : '?'
    \ }
let g:NERDTreeMinimalUI = 1

augroup NERDTree
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if
        \ argc() == 0
        \ && !exists('s:std_in')
        \ && winwidth(0) - g:NERDTreeWinSize > &l:textwidth
        \ | NERDTree | execute 'wincmd l'| endif
augroup END

map <C-h> :call <SID>jump_to_current()<cr>
imap <C-h> <C-o>:call <SID>jump_to_current()<cr>
map <C-t> :NERDTreeToggle<CR>
map <leader>t :call <sid>toggle_window_size()<cr>

function! s:close_if_only_control_win_left()
    if winnr('$') != 1
        return
    endif
    if (exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1)
            \ || &buftype == 'quickfix'
        q
    endif
endfunction

function! s:jump_to_current()
    execute('NERDTreeRefreshRoot')
    execute('NERDTreeFind')
    execute('vertical resize ' . g:NERDTreeWinSize)
endfunction

function! s:toggle_window_size()
    execute('NERDTreeFind')
    let l:max = 2 * g:NERDTreeWinSize
    let l:info = getwininfo(win_getid())[0]
    if l:info['width'] < l:max
        execute('vertical resize ' . l:max)
    else
        execute('vertical resize ' . g:NERDTreeWinSize)
    endif
endfunction

augroup close_if_only_control_win_left
  au!
  au BufEnter * call s:close_if_only_control_win_left()
augroup END
