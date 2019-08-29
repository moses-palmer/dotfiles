import re
import os
import types

from typing import Optional, Union

from . import Feature, curl, feature, system


#: The Rust compiler.
BIN_RUSTC = 'rustc'

#: The rustup binary.
BIN_RUSTUP = 'rustup'

#: The cargo binary.
BIN_CARGO = 'cargo'


@feature('The Rust programming language', {curl})
def main(env: Feature):
    if env.configuration['env']['distribution'] == 'termux':
        system.install_package(env, 'rust')
    else:
        with curl.get(env, 'https://sh.rustup.rs') as script:
            env.run('sh', script, '-y', '--no-modify-path')


@main.checker
def is_installed(env: Feature):
    return system.present(env, BIN_RUSTC)


def binary(
    name: str,
    crate: str,
    description: str,
    *args: Union[str, Feature, types.ModuleType],
) -> Feature:
    """Defines a cargo installable binary.

    :param name: The name of the binary.

    :param crate: The name of the crate.

    :param description: A description.

    :param args: Additional dependencies.
    """
    @feature(description, {main} | set(args), name)
    def installer(env):
        run(
            env,
            BIN_CARGO, 'install', crate)

    @installer.checker
    def is_installed(env):
        return system.present(env, name)


def component(
    name: str,
    description: str,
    *args: Union[str, Feature, types.ModuleType],
):
    """Defines a component feature.

    :param name: The name of the component.

    :param description: A description.

    :param args: Additional dependencies.
    """
    @feature(description, {main} | set(args), name)
    def installer(env):
        run(
            env,
            BIN_RUSTUP, 'component', 'add', name)

    component_re = re.compile(
        r'^\s*{}(-[^ ]+)?\s+\(\s*installed\s*\)\s*$'.format(re.escape(name)))

    @installer.checker
    def is_installed(env):
        return any(
            component_re.match(line)
            for line in run(
                env,
                BIN_RUSTUP, 'component', 'list',
                capture=True,
                interactive=False).splitlines())

    return installer


def run(env: Feature, binary: str, *args: str, **kwargs: str):
    """Executes a rust binary.

    This function ensures that the absolute path to the binary is passed, to
    ensure that it can be found without sourcing the cargo configuration file.

    :param env: The feature environment.

    :param binary: The binary name.

    :param args: Additional command arguments.

    :param kwargs: Additional arguments.
    """
    return env.run(_qualify(binary), *args, **kwargs)


def _qualify(binary: str):
    """Generates a qualified path to a rust binary.

    If the local cargo directory exists, and contains a corrresponding
    executable, the absolute path of the file is returned, otherwise
    ``binary```is returned.

    :param binary: The name of the binary.

    :return: a path
    """
    path = os.path.join(os.path.expanduser('~/.cargo/bin'), binary)
    if os.access(path, os.X_OK):
        return path
    else:
        return binary
