" Ensure vim-plug is available
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin()

for f in split(glob('~/.config/vim/plugins/*.vim'), '\n')
    exe 'source' f
endfor

call plug#end()
