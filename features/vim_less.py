import os

from . import Feature, feature, system, vim


BIN = '__vim-less'
TARGET = os.path.join(os.path.expanduser('~/'), '.local', 'bin', BIN)


@feature('Vim pager', {'vim'})
def vim_less(env: Feature):
    source = os.path.join(vim.runtime(env), 'macros', 'less.sh')
    os.symlink(source, TARGET)


@vim_less.checker
def is_installed(env: Feature):
    return os.path.islink(TARGET)
