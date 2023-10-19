import re
import shlex
import sys

from typing import Optional

from . import Feature, feature, system


#: The pip module name.
MOD = 'pip'


@feature('Python package installer')
def main(env):
    system.install_package(
        env,
        'python3-pip')


@main.checker
def is_installed(env):
    return env.run(
        sys.executable, '-m', MOD, '--version',
        check=True,
        interactive=False,
        silent=True)


def package(name: str, description: Optional[str] = None) -> Feature:
    """Defines a pip feature.

    :param name: The name of the package.

    :param description: A description.
    """
    def installer(env: Feature):
        install_package(
            env,
            name)
    installer.__name__ = name
    installer = feature(description or name, {main})(installer)

    @installer.checker
    def is_installed(env: Feature) -> bool:
        return present(
            env,
            name)

    return installer


def install_package(env: Feature, package: str):
    """Installs a package using ``pip``.

    :param env: The feature environment.

    :param package: The package name.
    """
    env.run(
        sys.executable, '-m', MOD, 'install', '--user', '--upgrade',
        *shlex.split(env.configuration['commands'].get(
            'pip_install_arguments',
            '')),
        '${package}',
        interactive=False,
        package=package)


def present(env: Feature, package: str):
    """Checks whether a package is installed.

    :param env: The feature environment.

    :param package: The package name.

    :return: whether the package is installed
    """
    regex = re.compile(
        r'(?i)^\s*{}\s+.*$'.format(
            re.sub(r'[-_]', '[-_]', package)))
    return any(
        regex.match(line)
        for line in env.run(
            sys.executable, '-m', MOD, 'list',
            capture=True,
            interactive=False).splitlines())
