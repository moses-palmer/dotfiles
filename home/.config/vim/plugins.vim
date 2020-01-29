set rtp+=~/.vim/bundle/Vundle.vim
filetype off
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

for f in split(glob('~/.config/vim/plugins/*.vim'), '\n')
    exe 'source' f
endfor

call vundle#end()
filetype plugin indent on
