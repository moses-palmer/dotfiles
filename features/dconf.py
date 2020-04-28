import os

from typing import Sequence

from . import Feature, system


main = system.package(__name__.rsplit('.')[-1])


def list(env: Feature, path: str) -> Sequence[str]:
    """Lists all keys under a path.

    Any directory items will have a ``'/'`` suffix.

    :param env: The feature environment.

    :param path: The path to list. This must start and end with ``'/'``.

    :return: a list of items
    """
    return (
        item.rstrip()
        for item in env.run(
            'dconf', 'list', path, capture=True, interactive=False).splitlines()
        if item.strip())


def read(env: Feature, path: str) -> str:
    """Reads a specific key.

    :param env: The feature environment.

    :param path: The path to read. This must start with ``'/'``.

    :return: a value
    """
    return env.run(
        'dconf', 'read', path, capture=True, interactive=False).strip()


def write(env: Feature, path: str, value: str) -> str:
    """Writes a specific key.

    :param env: The feature environment.

    :param path: The path to read. This must start with ``'/'``.

    :param value: The value to write. This must be in a *GVariant* format.

    :return: a value
    """
    if not 'DISPLAY' in os.environ:
        print('\033[0;31m{}\033[0m'.format(
            'Cannot write dconf value {} = {} without $DISPLAY set'.format(
                path, value)))
        return
    return env.run(
        'dconf', 'write', path, value, interactive=False)
