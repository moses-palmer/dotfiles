import os

from . import Feature, brew, feature, system

#: The shell binary for Bash.
SHELL = '/usr/local/bin/bash'


@feature('Bash as default shell', {brew})
def main(env: Feature):
    system.install_package(env, 'bash', 'bash-completion')
    env.run('sudo', 'chsh', '-s', SHELL, os.getenv('USER'))


@main.checker
def is_installed(env: Feature):
    return SHELL in env.run(
        'dscl', '.', '-read', os.getenv('HOME'), 'UserShell',
        capture=True)
