import os

from . import Feature, feature, system, vim


BIN = '__vim-less'


@feature('vim less.sh', {'vim'})
def vim_less(env: Feature):
    source = os.path.join(vim.runtime(env), 'macros', 'less.sh')
    target = os.path.join(os.path.expanduser('~/'), '.local', 'bin', BIN)
    os.symlink(source, target)


@vim_less.checker
def is_installed(env: Feature):
    return system.present(env, BIN)
