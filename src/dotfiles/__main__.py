import argparse
import fnmatch
import os
import subprocess
import sys

from typing import Sequence, Set

from . import (
    CopyMethod,
    header,
    disabled,
    ignoring,
    installing,
    platforms,
    removing,
)
from .features import *
from .features import FEATURES

from .features.configuration import Configuration


#: The data root.
ROOT = sys.argv[1]

#: The source of files to copy.
SOURCE = os.path.join(ROOT, 'home')

#: The target directory.
TARGET = os.path.expanduser('~/')


def main(copy_method: CopyMethod, no_install_features: bool):
    # Generate a description of the system and then load the configuration
    (distribution, version) = platforms.current()
    configuration = Configuration(
        os.path.join(ROOT, 'configuration.conf'),
        os.path.join(ROOT, 'local.conf'),
        d=lambda *parts: platforms.Distribution('', *parts),
        distribution=distribution,
        v=lambda s: platforms.Version(s),
        version=version)

    # Apply the configuration
    for feature in FEATURES:
        feature.configuration = configuration
        feature.source = SOURCE

    # Copy files, install features and then remove files removed from the
    # repository
    header('Running on {}...'.format(distribution))
    copy_files(copy_method, set(configuration.get('ignored', [])))
    if not no_install_features:
        install_features()
    clean_removed()


def install_features():
    """Installs all features.
    """
    header('Installing features')

    for feature in (f for f in FEATURES if not f.blacklisted):
        feature.prepare()

    fmt = '{{description:{}}} \033[0;90m({{name}})'.format(
        max(len(f.description) for f in FEATURES))
    for feature in FEATURES:
        message = fmt.format(name=feature.name, description=feature.description)
        if feature.blacklisted:
            disabled(message)
        elif feature.present:
            ignoring(message)
        else:
            installing(message)
            feature.install()

    for feature in reversed(FEATURES):
        feature.complete()


def copy_files(copy_method: CopyMethod, ignores: Set[str]):
    """Copies all files.

    :param copy_method: The metod used to copy files.

    :param ignores: A set of ignored files.
    """
    header('Copying files')

    for filename in _collect_files(SOURCE):
        if _ignored(filename, ignores):
            disabled(filename)
        elif not copy_method.changed(SOURCE, TARGET, filename):
            ignoring(filename)
        else:
            installing(filename)
            copy_method.copy(SOURCE, TARGET, filename)


def clean_removed():
    """Removes all dot files that have been removed from the repository.

    If the dot file is a broken link, it is automatically removed, otherwise
    the user is asked first.
    """
    header('Removing deprecated files')

    for line in filter(lambda l: l.strip(), subprocess.check_output([
            'git', 'log',
            '--all',
            '--pretty=format:',
            '--name-only',
            '--diff-filter=D',
            '--', 'home']).decode('utf-8').splitlines()):
        relative = line.rstrip().split(os.path.sep, 1)[1]
        path = os.path.expanduser('~/{}'.format(relative))
        if os.path.islink(path):
            removing(relative)
            os.unlink(path)
            continue

        while os.path.exists(path):
            r = input('{} is removed. Remove from computer? [yes/no] '.format(
                path)).lower()
            if not r:
                pass
            elif r[0] == 'y':
                removing(relative)
                os.unlink(path)
                break
            elif r[0] == 'n':
                break


def _collect_files(source: str) -> Sequence[str]:
    """Returns a list of all files under ``source`` that are not in
    ``.gitignore``.

    The file names are relative to ``source``.

    :param source: The source directory.

    :return: a generator of file names
    """
    return sorted(
        os.path.relpath(os.path.join(root, filename), source)
        for root, dirs, filenames in os.walk(source)
        for filename in filenames)


def _ignored(filename: str, ignores: Set[str]) -> bool:
    """Determines whether a file is ignored for the current system.

    A file is ignored if it is matched by a glob pattern in ``ignores``.

    :param filename: The file name, relative to the source directory.

    :param ignores: A set of globs matching ignored files.

    :return: whether the file should be ignored
    """
    return any(
        fnmatch.fnmatch(filename, ignore)
        for ignore in ignores)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Installs features and dotfiles')

    parser.add_argument(
        '--copy-method',
        help='The method to use to copy files. Valid values are "link", which '
        'will create symlinks and "copy", which will copy the files. The '
        'default value is "link".',
        type=CopyMethod,
        default=CopyMethod.LINK)

    parser.add_argument(
        '--no-install-features',
        help='Do not install features.',
        action='store_true',
        default=False)

    try:
        main(**vars(parser.parse_args(sys.argv[2:])))
    except KeyboardInterrupt:
        print()
        print('Cancelled')
