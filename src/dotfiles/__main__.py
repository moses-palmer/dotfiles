import argparse
import fnmatch
import os
import sys

from typing import Generator, Sequence, Set

from . import (
    CopyMethod,
    disabled,
    header,
    ignoring,
    installing,
    platforms,
    query,
    removing,
)
from .features import *
from .features import FEATURES

from .features.configuration import Configuration


#: The data root.
ROOT = sys.argv[1]

#: A glob pattern matching files in the dotfile root directory.
ROOT_PATTERN = os.path.abspath(ROOT) + '/**'

#: The source of files to copy.
SOURCE = os.path.join(ROOT, 'home')

#: The target directory.
TARGET = os.path.expanduser('~/')

#: Names of directories ignored when listing files to clean.
IGNORED_DIRECTORIES = (
    '.cache/jedi',
    '.cache/pip',
    '.cache/vim/swap',
    '.cargo',
    '.rustup',
    '.vim/plugged',
    '**/.git',
)


def main(
    copy_method: CopyMethod,
    no_install_features: bool,
    no_clean: bool,
):
    # Generate a description of the system and then load the configuration
    (distribution, version) = platforms.current()
    configuration = Configuration(
        os.path.join(ROOT, 'configuration.conf'),
        os.path.join(ROOT, 'local.conf'),
        d=lambda *parts: platforms.Distribution('', *parts),
        distribution=distribution,
        python_version=platforms.Version(tuple(sys.version_info[:3])),
        v=lambda s: platforms.Version(s),
        version=version)

    # Apply the configuration
    for feature in FEATURES:
        feature.configuration = configuration
        feature.source = SOURCE

    # Copy files, install features and then remove files removed from the
    # repository
    header('Running on {}...'.format(distribution))
    ignores = set(configuration.get('ignored', []))
    copy_files(copy_method, ignores)
    if not no_install_features:
        install_features()
    if not no_clean:
        clean(ignores)


def install_features():
    """Installs all features.
    """
    header('Installing features')

    for feature in (f for f in FEATURES if not f.blacklisted):
        feature.prepare()

    fmt = '{{description:{}}} \033[0;90m({{name}})'.format(
        max(len(f.description) for f in FEATURES))
    for feature in FEATURES:
        message = fmt.format(
            name=feature.name,
            description=feature.description)
        if feature.blacklisted:
            disabled(message)
        elif feature.present:
            ignoring(message)
        else:
            installing(message)
            feature.install()

    for feature in reversed([f for f in FEATURES if not f.blacklisted]):
        feature.complete()

    print()


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

    print()


def clean(ignores: Set[str]):
    """Removes stale links from the home directory.

    A stale link is a link pointing into this repository that is either invalid
    or points to an ignored file.

    :param ignores: A set of ignored files.
    """
    header('Removing deprecated files')

    for (link, target) in _dotfile_links(ROOT_PATTERN, _all_files(TARGET)):
        rel = os.path.relpath(target, SOURCE)
        if _ignored(rel, ignores):
            removing('{} is ignored'.format(rel))
        elif not os.path.isfile(target):
            removing('{} has been removed'.format(rel))
        else:
            continue
        response = query(
            'Remove {} from computer?'.format(link),
            'yes', 'no')
        if response == 'yes':
            os.unlink(link)
        elif response is None:
            print('  Not removing as we are not running in a terminal.')

    print()


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


def _all_files(directory: str) -> Generator[str, None, None]:
    """Generates files under ``directory``.

    Directories with a name in ``IGNORED_DIRECTORIES`` are ignored.

    :param directory: The root directory.
    """
    for (root, dirs, files) in os.walk(directory):
        dirs[:] = [
            d
            for d in dirs
            if not any(
                fnmatch.fnmatch(
                    os.path.relpath(os.path.join(root, d), directory),
                    i)
                for i in IGNORED_DIRECTORIES)]
        yield from (os.path.join(root, f) for f in files)


def _dotfile_links(
    target_pattern: str,
    files: Sequence[str],
) -> Generator[str, None, None]:
    """Filters a sequence of files so that only those that are links to targets
    matching ``target_pattern`` remain.

    :param target_pattern: The file glob to find relevant targets.
    :param files: A sequence of file names.
    """
    yield from (
        (link, target)
        for (link, target) in (
            (f, os.readlink(f))
            for f in (
                f
                for f in files
                if os.path.islink(f)))
        if fnmatch.fnmatch(target, target_pattern))


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

    parser.add_argument(
        '--no-clean',
        help='Do not clean stale links.',
        action='store_true',
        default=False)

    try:
        main(**vars(parser.parse_args(sys.argv[2:])))
    except KeyboardInterrupt:
        print()
        print('Cancelled')
