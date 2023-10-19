import functools
import importlib
import os
import re
import sys

from typing import Tuple


#: The regular expression used to extract values from lines in the information
#: file.
LINE_RE = re.compile(r'^([a-zA-Z][a-zA-Z0-9_]*)=(")?(.*?)\2?$')


class Distribution:
    """A representation of a distribution.

    A distribution has a display name and a path. The path is a sequence of IDs
    such as ``'debian/ubuntu'``. When performing comparisons, any part of a
    path matches.
    """
    def __init__(self, name, *parts):
        self._name = name
        self._parts = parts

    def __str__(self):
        return self._name

    def __eq__(self, o):
        parts = set(
            o._parts
            if isinstance(o, self.__class__) else
            str(o).split('/'))
        return bool(set(self._parts).intersection(parts))

    @property
    def identity(self):
        return '/'.join(self._parts)


@functools.total_ordering
class Version:
    """A representation of a version.

    A version is a sequence of numbers.
    """
    def __init__(self, s):
        if isinstance(s, tuple):
            self._version = s
        elif isinstance(s, str):
            self._version = tuple(int(p) for p in s.split('.'))
        else:
            raise ValueError(s)

    def __str__(self):
        return '.'.join(self._version)

    def __eq__(self, o):
        return str(self) == str(o)

    def __lt__(self, o):
        return self._version < o._version


def current() -> Tuple[Distribution, Version]:
    """Attempts to determine the current platform.

    :return: the tuple ``(platform_name, platform_version)``
    """
    try:
        # First attempt to read an information file...
        with open('/etc/os-release', encoding='utf-8') as f:
            values = {
                m.group(1): m.group(3)
                for m in (
                    LINE_RE.match(line)
                    for line in f
                    if LINE_RE.match(line))}

        return (
            Distribution(
                values['PRETTY_NAME'],
                *(
                    (values['ID_LIKE'], values['ID'])
                    if 'ID_LIKE' in values else
                    (values['ID'],))),
            Version(values['VERSION_ID']))

    except (KeyError, FileNotFoundError):
        # ...then fall back on detection
        module_names = (
            name.rsplit('.', 1)[0]
            for name in os.listdir(os.path.dirname(__file__))
            if name[0] != '_' and name.endswith('.py'))

        for module_name in module_names:
            module = importlib.import_module('.' + module_name, __package__)
            try:
                return module.information()
            except:
                pass

    print('The current platform is not supported')
    sys.exit(1)
