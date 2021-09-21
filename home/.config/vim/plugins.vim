" Ensure vim-plug is available
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin()

if exists('$VIM_PLUGINS')
    for plugin in split($VIM_PLUGINS, ':')
        exe 'source' '~/.config/vim/plugins/' . plugin . '.vim'
    endfor
else
    for f in split(glob('~/.config/vim/plugins/*.vim'), '\n')
        exe 'source' f
    endfor
endif

call plug#end()
