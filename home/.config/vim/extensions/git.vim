command! Gblame call RunShellCommand(
    \ 'git blame '.expand('%'), b:current_syntax)
command! Gdiff call RunShellCommand(
    \ 'git diff '.expand('%'), 'diff')
command! -nargs=+ Gshow call RunShellCommand(
    \ 'git show '.<q-args>.':'.expand('%'), b:current_syntax)

command! Glog term git logg %
