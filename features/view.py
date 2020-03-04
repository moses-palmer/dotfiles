import os

from . import Feature, feature, system, vim


BIN = 'view'
TARGET = os.path.join(os.path.expanduser('~/'), '.local', 'bin', BIN)


@feature('Improved view', {vim})
def view(env: Feature):
    source = os.path.join(vim.runtime(env), 'macros', 'less.sh')
    os.symlink(source, TARGET)


@view.checker
def is_installed(env: Feature):
    return os.path.islink(TARGET)
