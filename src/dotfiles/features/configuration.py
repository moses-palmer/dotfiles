"""
The configuration reader
------------------------

This module contains :class:`Configuration`, a representation of the current
system.

A configuration is read from a number of files, not all of which must be
actually present. A configuration file is similar in structure to an INI file,
with the following exceptions:

1. **Keys without values are allowed.** In addition to value lines like
   ``key=value``, lines like ``key`` are also allowed. These can be used as
   flags or to define lists of strings.
2. **Section names may contain arbitrary Python expressions.** Any text data
   following :attr:`Configuration.SEPARATOR` in a section name is interpreted
   as a Python expression, and is evaluated using a global scope passed when
   the configuration is loaded. The final configuration object will only
   contain data from sections where the expression evaluates to ``True``.

Example::

    [common]
    key=value

    [other :: distribution == 'my-dist' and version >= v('10.1')]
    key=value

This will return a configuration where ``configuration['common']['key'] ==
'value'``, and ``configuration['other']['key'] == 'value'`` if
``values['distribution'] == 'my-dist'`` and ``values['version'] >= v('10.1')``.

``distribution``, ``v`` and ``version`` are passed as keyword arguments to the
Configuration constructor.
"""
import configparser

from typing import Any, Dict, Sequence, Tuple


class Configuration(dict):
    #: The string separating a section name from its predicates.
    SEPARATOR = '::'

    #: A section added to all configurations containing the original values
    #: passed.
    ENV_SECTION = 'env'

    def __init__(self, *filenames: str, **values):
        """Initialises a configuration object.

        A configuration object is a collection of sections and corresponding
        values. The format of a configuration file resembles a plain INI file,
        but it supports additional metadata in the section headers.

        :param filenames: The source files. Non-existing files are simply
            ignored: it is not an error to pass invalid file names as per the
            specification in :meth:`configparser.ConfigParser.read`.

        :param values: Distribution specific values.
        """
        data = {
            self.ENV_SECTION: values}
        self._values = values
        for filename in filenames:
            values = self._extract_values(filename, values)
            for (section, values) in values.items():
                if section == self.ENV_SECTION:
                    raise ValueError('the section {} is reserved'.format(
                        self.ENV_SECTION))
                try:
                    data[section].update(values)
                except KeyError:
                    data[section] = dict(values)

        super().__init__(data)

    def __getattr__(self, key: str) -> str:
        try:
            return self._values[key]
        except KeyError:
            raise AttributeError(key)

    def _extract_values(
            self, filename: str, values: Dict[str, Any]) -> Dict[str, str]:
        """Extracts all applicable sections from a file.

        :param filename: The configuration file to parse.

        :param values: Distribution specific values used to filter the sections
            to return.

        :return: a mapping from normalised section name to entries
        """
        result = {}
        for (section, expression, entries) in self._extract_sections(filename):
            if eval(expression, values):
                try:
                    result[section].update(entries)
                except KeyError:
                    result[section] = dict(entries)

        return result

    def _extract_sections(
            self, filename: str) -> Sequence[Tuple[str, str, str]]:
        """Extracts all section from a file.

        This method yields the tuple ``(section, expression, entries)``, where
        ``section`` is the normalised name of the section, ``expression`` is a
        code object that can be evaluated to determine whether to include the
        section, and ``entries`` are the actual values.

        If ``filename`` cannot be read, this method does not raise an error;
        rather, it yields an empty sequence.

        :param filename: The configuration file to read.
        """
        configuration = configparser.ConfigParser(allow_no_value=True)
        configuration.optionxform = str
        configuration.read(filename)
        for (key, entries) in configuration.items():
            try:
                section, expression = key.split(self.SEPARATOR, 1)
            except ValueError:
                section, expression = key, str(True)
            yield (
                section.strip(),
                compile(expression.strip(), filename, 'eval'),
                entries)
