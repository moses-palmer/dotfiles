"""
Features
--------

Features are components that are added to the system, but are not simple files.
This includes applications and services. Some may need administrative
privileges to apply.
"""
import os
import re
import shlex
import subprocess
import sys
import types

from typing import Callable, Optional, Set, Union

from .configuration import Configuration

#: The path to feature modules.
FEATURE_PATH = os.path.join(
    os.path.dirname(__file__),
    os.path.pardir,
    os.path.pardir,
    os.path.pardir,
    'features')

__path__ = (
    os.path.dirname(__file__),
    FEATURE_PATH)
__all__ = tuple(
    name.split('.', 1)[0]
    for name in os.listdir(FEATURE_PATH)
    if name[0] not in '._')


#: The regex used to extract feature modules.
MODULE_RE = re.compile(r'[a-zA-Z][a-zA-Z0-9_]*?\.py')

#: The regex used to extract interpolation tokens.
TOKEN_RE = re.compile(r'\${([^}]+)}')

#: The registered features.
FEATURES = []

#: A function to determine whether a feature is already present.
PresentCallback = Callable[['self'], None]

#: A function to prepare the feature for being installed.
PrepareCallback = Callable[['self'], None]

#: A function to actually install a feature.
InstallCallback = Callable[['self'], None]

#: A function to complete installation of this feature.
CompleteCallback = Callable[['self'], None]


class Feature:
    def __init__(
            self, installer: InstallCallback, name: str, description: str,
            dependencies: Set[str]):
        self._installer = types.MethodType(installer, self)
        self._checker = types.MethodType(lambda *_: False, self)
        self._preparer = types.MethodType(lambda *_: None, self)
        self._completer = types.MethodType(lambda *_: None, self)

        self._name = name
        self._description = description
        self._dependencies = dependencies

        self._configuration = Configuration()
        self._present = None

        if any(feature.name == name for feature in FEATURES):
            raise RuntimeError('Feature "{}" added twice'.format(
                name,
                str(self)))
        else:
            FEATURES.append(self)

    def __str__(self):
        return '{} - {}'.format(self.name, self.description)

    def checker(self, checker: PresentCallback) -> PresentCallback:
        """A decorator to mark a callable as the availability checker for this
        feature.
        """
        self._checker = types.MethodType(checker, self)
        return checker

    def preparer(self, preparer: PrepareCallback) -> PrepareCallback:
        """A decorator to mark a callable as the preparer callback for this
        feature.
        """
        self._preparer = types.MethodType(preparer, self)
        return preparer

    def completer(self, completer: CompleteCallback) -> CompleteCallback:
        """A decorator to mark a callable as the completer callback for this
        feature.
        """
        self._completer = types.MethodType(completer, self)
        return completer

    @property
    def name(self) -> str:
        """The name of this feature.
        """
        return self._name

    @property
    def description(self) -> str:
        """The description of this feature.

        If none has been set, this will fall back on :attr:`name`.
        """
        return (
            self._description
            if self._description is not None else
            self.name)

    @property
    def dependencies(self):
        """The dependencies of this feature.
        """
        try:
            return [
                next(
                    f
                    for f in FEATURES
                    if f.name == dependency)
                for dependency in self._dependencies]
        except StopIteration:
            raise RuntimeError(
                    'Feature {} has unmet dependencies: {} '
                    '(available features: {})'.format(
                    str(self),
                    ', '.join(
                        n
                        for n in self._dependencies
                        if not any(
                            f.name == n
                            for f in FEATURES)),
                    ', '.join(f.name for f in FEATURES)))

    @property
    def configuration(self) -> Configuration:
        """The current configuration.
        """
        return self._configuration

    @configuration.setter
    def configuration(self, value: Configuration):
        self.configuration.clear()
        self.configuration.update(value.items())

    @property
    def present(self) -> bool:
        """Whether the feature is currently present.

        Once this method is called, the value is only updated after
        :meth:`install` has been called.
        """
        if self._present is None:
            self._present = self._checker()
        return self._present

    @property
    def blacklisted(self) -> bool:
        """Whether this feature is blacklisted for the current distribution.
        """
        return self.name in self.configuration.get('blacklist', set()) or any(
            dependency.blacklisted
            for dependency in self.dependencies)

    def install(self):
        """Installs this feature.

        This method does not check whether this feature is already installed.
        """
        self._installer()
        self._present = None

    def prepare(self):
        """Prepares this feature for being installed.

        This method of all features is called in order before installing or
        checking.
        """
        self._preparer()

    def complete(self):
        """Runs the complete callback.

        This method of all feature is called in reversed order after installing
        or checking.
        """
        self._completer()

    def run(
            self, *args, check=False, capture=False, interactive=True,
            silent=False, **kwargs) -> Union[bool, str]:
        """Runs a command.

        Unless ``check`` is ``True``, this method will call :func:`sys.exit` if
        the command fails.

        :param check: Whether to capture errors and return ``False`` instead of
            aborting the process.

        :param capture: Whether to capture output. If this is true, this
            function will return the output data.

        :param interactive: Whether to run the command interactively. If this
            is not true, no input can be passed, otherwise ``stdin`` will be
            connected to the current ``stdin``.

        :param silent: Whether to suppress all output.

        :param args: The command and arguments as a sequence of strings.

        :param kwargs: Any token values used as replacements for strings on the
            form ``'${token_name}'``.

        :returns: whether the command succeeded if ``capture`` is ``False``,
            otherwise the command output
        """
        assert not (check and capture)
        assert not (capture and silent)

        # Override stdin to /dev/null if not interactive to force immediate
        # error
        ins = (
            subprocess.DEVNULL
            if not interactive else
            None)

        # Allow reading stdout if capturing, hide if silent, otherwise just
        # display it
        outs = (
            subprocess.PIPE
            if capture else
            subprocess.DEVNULL
            if silent else
            None)

        # Perform string interpolation on kwargs for all command arguments
        args = [
            TOKEN_RE.sub(
                lambda m: (
                    shlex.quote(kwargs[m.group(1)])
                    if m.group(1) in kwargs else
                    m.group(0)),
                arg)
            for arg in args]

        p = subprocess.Popen(args, stdin=ins, stdout=outs, stderr=outs)
        stdout, _ = p.communicate()
        if p.returncode == 0:
            return stdout.decode('utf-8') if capture else True
        elif check:
            return False

        # We failed; terminate the process
        print('Command {} for {} failed'.format(' '.join(args), self.name))
        sys.exit(1)


def feature(
        description: str,
        dependencies: Set[Union[str, Feature, types.ModuleType]] = set(),
        name: Optional[str] = None) -> Feature:
    """A decorator that registers a callable as a feature.

    The returned values has the additional attribute ``checker`` which can be
    applied as a decorator to a function checking whether the feature already
    is installed.

    :param description: A description of the feature.

    :param dependencies: The names of features on which this feature depends.

    :param name: The name of the feature. If this is not specified, the name of
        the decorated function is used, unless it is ``'main'``, in which case
        the module name is used instead.
    """
    return lambda func: Feature(
        func,
        name or (
            func.__globals__['__name__'].rsplit('.', 1)[-1]
            if func.__name__ == 'main'
            else func.__name__),
        description,
        {
            d.name if isinstance(d, Feature) else
            d.main.name if isinstance(d, types.ModuleType) else
            d
            for d in dependencies})
