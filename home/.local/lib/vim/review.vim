execute('source ' . expand('<sfile>:p:h') . '/app.vim')

" Set options appropriate for reviewing
set colorcolumn=0
set laststatus=2
set lazyredraw
set noexpandtab
set nolist
set nomodifiable
set nomodified
set nonumber
set noshowcmd
set noshowmode
set noswapfile
set nowrap
set readonly

nnoremap <PageUp> :call <SID>jump_to_file('b')<CR>
nnoremap <PageDown> :call <SID>jump_to_file('')<CR>
nnoremap <S-PageUp> :call <SID>jump_to_commit('b')<CR>
nnoremap <S-PageDown> :call <SID>jump_to_commit('')<CR>
nnoremap <leader>g :call <SID>open_modifications()<CR>
nnoremap <2-LeftMouse> :call <SID>open_modifications()<CR>
nnoremap <buffer> <F10> :call <SID>toggle_word_diff()<CR>

" Whether to use a word diff for change listing
let g:review#word_diff = 1

" The main window is the parent window
let g:review#win_parent = win_getid()


" Create the chunk signs
execute('sign define review_s text=↘ linehl= texthl=SignColumn')
execute('sign define review_c text=→ linehl=DiffText texthl=SignColumn')
execute('sign define review_e text=↗ linehl= texthl=SignColumn')

" The change listing is ANSI coded
AnsiEsc


" Loads the change listing.
function! s:load_changes()
    " Update the current file name
    file $REVIEW_SOURCE -> $REVIEW_TARGET

    " Make sure we focus the parent window
    call s:goto_parent()

    " Store the current file and commit so we can return; move one line down to
    " include the current line although we search backwards
    execute('normal j')
    if search('diff --git ', 'bcW')
        let l:path = getline('.')
        call search('commit [0-9a-h]\{7\}', 'bcW')
        let l:commit = split(getline('.'))[1]
    endif

    " Allow modifications while we update
    setlocal modifiable

    " Clear the buffer
    execute('%d')

    " Read the change listing
    if g:review#word_diff
        let l:git_command = 'lc --ignore-all-space'
    else
        let l:git_command = 'log --patch --color=always'
    endif
    silent! execute('0read !' .
        \ 'git ' .
        \ l:git_command . ' ' .
        \ '--unified=1 ' .
        \ '--reverse ' .
        \ $REVIEW_TARGET . '..' . $REVIEW_SOURCE)
    AnsiEsc!
    setlocal nomodified

    " Move to a sensible location
    execute('0')
    if exists('l:commit')
        call search('commit ' . l:commit, '')
        call search(l:path, '')
        execute('normal zt')
    endif

    set modifiable<

    " Add buffer local mappings to quit
    nnoremap <buffer> <leader>q :qa<CR>
endfunction


" Finds the files for the current git diff section and opens them in new
" windows.
function! s:open_modifications()
    " Find the header line before the current line
    let l:m = s:find_header(line('.'))
    if empty(l:m)
        echo('Failed to locate diff file header.')
        return
    else
        let [l:lineno, l:path_a, l:path_b] = l:m
    endif

    " Find the start of the current hunk
    let l:m = s:find_hunk(line('.'))
    if empty(l:m)
        let [l:hunk_a_lineno, l:hunk_b_lineno] = [1, 1]
    else
        let [l:hunk_a_lineno, l:hunk_b_lineno] = l:m
    endif

    " Find the revisions
    let l:m = s:extract_revisions(getline(l:lineno + 1))
    if empty(l:m)
        echo('Failed to locate revisions.')
        return
    else
        let [l:rev_a, l:rev_b] = l:m
    endif

    " Close any previous child windows
    if s:goto_parent()
        call s:close_modifications()
    endif

    " Find the chunks
    let [l:chunks_a, l:chunks_b] = s:find_chunks(l:lineno)

    " Open the files
    below vnew
    let l:win_a = win_getid()
    silent! call s:open_at_rev(
        \ 'a', l:path_a, l:rev_a, l:chunks_a, l:hunk_a_lineno)

    belowright new
    let l:win_b = win_getid()
    silent! call s:open_at_rev(
        \ 'b', l:path_b, l:rev_b, l:chunks_b, l:hunk_b_lineno)

    " Return to the main window and store the child window IDs
    call s:goto_parent()
    let w:review_win_a = l:win_a
    let w:review_win_b = l:win_b
    let g:review#zoomed = 0

    " Add buffer local mappings for diff interactions
    nnoremap <buffer> <Up> :call <SID>for_children("normal k")<CR>
    nnoremap <buffer> <Down> :call <SID>for_children("normal j")<CR>
    nnoremap <buffer> <Left> :call <SID>for_children("normal h'")<CR>
    nnoremap <buffer> <Right> :call <SID>for_children("normal l'")<CR>
    nnoremap <buffer> <PageUp> :call <SID>for_children("normal ['")<CR>
    nnoremap <buffer> <PageDown> :call <SID>for_children("normal ]'")<CR>
    nnoremap <buffer> <leader>q :call <SID>close_modifications()<CR>
    nnoremap <buffer> <F9> :call <SID>toggle_zoom()<CR>
endfunction


" Restores the state after having viewed diff files.
function! s:close_modifications()
    if !s:goto_parent() || !s:has_children()
        return
    endif

    call s:for_children('wincmd c')
    call s:goto_parent()
    unlet w:review_win_a
    unlet w:review_win_b

    " Restore mappings
    mapclear <buffer>
    nnoremap <buffer> <leader>q :qa<CR>
endfunction


" Toggles word diff mode.
function! s:toggle_word_diff()
    let g:review#word_diff = !g:review#word_diff
    call s:load_changes()
endfunction


" Toggles zooming of the parent window.
function! s:toggle_zoom()
    if !s:goto_parent() || !s:has_children()
        return
    endif
    let l:win_a = w:review_win_a
    let l:win_b = w:review_win_b

    let g:review#zoomed = !g:review#zoomed
    if g:review#zoomed
        call s:for_child(l:win_a, 'wincmd H')
        call s:for_child(l:win_b, 'wincmd L')
        call s:for_parent('wincmd J')
        call s:for_parent('resize 1')
    else
        call s:for_child(l:win_a, 'wincmd K')
        call s:for_child(l:win_b, 'wincmd J')
        call s:for_parent('wincmd H')
    endif
endfunction


" Jumps to a file by searching for a file diff header line.
function! s:jump_to_file(flags)
    call search('^[^\p]*diff --git a/.*', a:flags)
    execute('normal zt')
endfunction


" Jumps to a commit by searching for a commit header line.
function! s:jump_to_commit(flags)
    call search('^[^\p]*commit [0-9a-f]\{7\}', a:flags)
    execute('normal zt')
endfunction


" Determines whether the child window IDs exist.
function! s:has_children()
    return exists('w:review_win_a') && exists('w:review_win_b')
endfunction


" Executes a command in all diff-open child windows.
function! s:for_children(cmd)
    if !s:goto_parent() || !s:has_children()
        return
    endif

    for l:win_id in [w:review_win_a, w:review_win_b]
        call s:for_child(l:win_id, a:cmd)
    endfor

    call s:goto_parent()
endfunction


" Executes a command for a child window.
function! s:for_child(win_id, cmd)
    let l:winnr = win_id2win(a:win_id)
    if l:winnr > 0
        execute(l:winnr . 'wincmd w')
        execute(a:cmd)
    endif
endfunction


" Executes a command for the parent window.
function! s:for_parent(cmd)
    if s:goto_parent()
        execute(a:cmd)
    endif
endfunction


" Finds the currently selected commit.
function! s:find_commit(lineno)
    let l:lineno = a:lineno
    while l:lineno > 0
        let l:m = matchlist(getline(l:lineno), 'commit \([a-h0-9]\{7\}\)')
        if empty(l:m)
            let l:lineno = l:lineno - 1
            continue
        else
            return l:m[1]
        endif
    endwhile
endfunction


" Finds the diff header by starting at the current line and moving up until a
" header is found.
function! s:find_header(lineno)
    let l:lineno = a:lineno
    while l:lineno > 0
        let l:m = s:extract_header(getline(l:lineno))
        if empty(l:m)
            let l:lineno = l:lineno - 1
            continue
        else
            let [l:file_a, l:file_b] = l:m

            " If this is a new or deleted file, skip the line stating that
            if !empty(matchlist(
                    \ getline(l:lineno + 1),
                    \ '\(deleted\|new\) file mode [0-9]*'))
                let l:lineno = l:lineno + 1
            endif

            return [l:lineno, l:file_a, l:file_b]
        endif
    endwhile
endfunction


" Finds the hunk header by starting at the current line and moving up until a
" header is found.
function! s:find_hunk(lineno)
    let l:lineno = a:lineno
    while l:lineno > 0
        let l:m = s:extract_hunk(getline(l:lineno))
        if empty(l:m)
            let l:lineno = l:lineno - 1
            continue
        else
            return l:m
        endif
    endwhile
endfunction


" Finds chunk data following the git diff header at s:lineno.
"
" The search is continued until the end of the buffer, or until a new git diff
" header is encountered.
function! s:find_chunks(lineno)
    let l:chunks_a = []
    let l:chunks_b = []

    let l:lineno = a:lineno
    while l:lineno <= line('$')
        let l:lineno = l:lineno + 1
        let l:m = s:extract_line_numbers(getline(l:lineno))
        if empty(l:m)
            let l:m = s:extract_header(getline(l:lineno))
            if empty(l:m)
                continue
            else
                break
            endif
        else
            let [l:lineno_a, l:count_a, l:lineno_b, l:count_b] = l:m
            call add(l:chunks_a, [l:lineno_a, l:lineno_a + l:count_a])
            call add(l:chunks_b, [l:lineno_b, l:lineno_b + l:count_b])
        endif
    endwhile

    return [l:chunks_a, l:chunks_b]
endfunction


" Opens a file at a specific revision.
"
" The file is opened in read only mode. A mark is added for each chunk.
function! s:open_at_rev(prefix, path, rev, chunks, lineno)
    " Open the file at the specified revision
    let l:file = a:prefix . '/' . a:path
    setlocal bufhidden=wipe
        \ buftype=nofile
        \ modifiable
        \ nobuflisted
        \ nowrap
        \ number
    if a:rev != '0000000'
        execute('0read !git show ' . a:rev . ' -- ' . a:path)
        execute('file ' . l:file)
        execute('filetype detect')
    endif
    setlocal nomodifiable

    " Add signs and marks for the chunks
    let l:i = 0
    let l:s = 1
    let l:mark = char2nr('a')
    let l:max = char2nr('z') - l:mark
    for [l:start, l:end] in a:chunks
        let l:j = l:start
        while l:j < l:end
            if l:j == l:start
                let l:sign = 'review_s'
            elseif l:j == l:end - 1
                let l:sign = 'review_e'
            else
                let l:sign = 'review_c'
            endif
            execute('sign place ' . l:s . ' '
                \ . 'line=' . l:j . ' '
                \ . 'name=' . l:sign . ' '
                \ . 'buffer=' . bufnr('$'))
            let l:s = l:s + 1
            let l:j = l:j + 1
        endwhile
        if l:i < l:max
            execute(l:start . 'ma ' . nr2char(l:mark + l:i))
            let l:i = l:i + 1
        endif
    endfor

    " Go to the specified line
    execute('normal ' . a:lineno . 'Gz.')

    " Add useful mappings
    nnoremap <buffer> <leader>q :silent! call <SID>close_modifications()<CR>
    nnoremap <buffer> k <C-y>
    nnoremap <buffer> j <C-e>
    nnoremap <buffer> h zh
    nnoremap <buffer> l zl
endfunction


" Attempts to extract the a and b filenames from a git diff header.
function! s:extract_header(s)
    let l:m = matchlist(
        \ a:s,
        \ 'diff --git a/\([^\e]*\) b/\([^\e]*\)')
    if !empty(l:m)
        return [l:m[1], l:m[2]]
    else
        return []
    endif
endfunction


" Attempts to extract the hunk start line from a hunk header.
function! s:extract_hunk(s)
    let l:m = matchlist(
        \ a:s,
        \ '@@ -\([0-9]*\),\([0-9]*\) +\([0-9]*\),\([0-9]*\) @@')
    if !empty(l:m)
        return [l:m[1], l:m[3]]
    else
        return []
    endif
endfunction


" Attempts to extract the revisions from a git index line.
function! s:extract_revisions(s)
    let l:m = matchlist(
        \ a:s,
        \ 'index \([0-9a-h]*\)\.\.\([0-9a-h]*\)')
    if !empty(l:m)
        return [l:m[1], l:m[2]]
    else
        return []
    endif
endfunction


" Attempts to extract line number information from a git hunk header.
function! s:extract_line_numbers(s)
    let l:m = matchlist(
        \ a:s,
        \ '@@ -\([0-9]*\),\([0-9]*\) +\([0-9]*\),\([0-9]*\) @@')
    if !empty(l:m)
        return [l:m[1], l:m[2], l:m[3], l:m[4]]
    else
        return []
    endif
endfunction


" Moves to the review parent window.
function! s:goto_parent()
    if exists('g:review#win_parent')
        let l:winnr = win_id2win(g:review#win_parent)
        if l:winnr > 0
            execute(l:winnr . 'wincmd w')
            return 1
        else
            echo('Failed to find review window.')
            return 0
        endif
    else
        return 0
    endif
endfunction


call s:load_changes()
