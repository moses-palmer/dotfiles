import os

from . import Feature, feature, git, vim


#: The Vundle source repository.
SOURCE_REPO = 'https://github.com/VundleVim/Vundle.vim'

#: The Vundle installation path.
TARGET_DIRECTORY = os.path.expanduser('~/.vim/bundle/Vundle.vim')


@feature('vim plugin installer', {'git', 'vim'})
def main(env: Feature):
    git.clone(env, SOURCE_REPO, TARGET_DIRECTORY)


@main.checker
def is_installed(env: Feature) -> bool:
    return os.path.isdir(TARGET_DIRECTORY)


@main.completer
def install_plugins(env: Feature):
    if env.present:
        vim.run(env, '+PluginInstall', '+qall')
