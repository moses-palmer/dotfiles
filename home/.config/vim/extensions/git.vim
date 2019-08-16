command! Gdiff call RunShellCommand(
    \ 'git diff '.expand('%'), 'diff')
command! -nargs=+ Gshow call RunShellCommand(
    \ 'git show '.<q-args>.':'.expand('%'), b:current_syntax)

command! Glog term git logg %
