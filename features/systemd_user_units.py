import os

from typing import Sequence

from . import Feature, feature


@feature('Systemd user units')
def main(env: Feature):
    for unit in (
            unit
            for unit in units(env)
            if not enabled(env, unit)):
        enable(env, unit)


@main.checker
def is_enabled(env: Feature):
    return all(
        enabled(env, unit)
        for unit in units(env))


def units(env: Feature) -> Sequence[str]:
    """Lists the names of all user units.

    :param env: The feature environment.

    :return: a list of unit names, including extension
    """
    directory = os.path.join(env.source, '.config', 'systemd', 'user')
    return filter(
        lambda p: os.path.isfile(os.path.join(directory, p)),
        os.listdir(directory))


def enabled(env: Feature, unit: str) -> bool:
    """Determines whether a user unit file is enabled.

    This function will return ``False`` if the unit name is invalid.

    :param env: The feature environment.

    :param unit: The unit name.

    :return: whether the unit is enabled
    """
    return env.run(
        'systemctl', '--user', 'is-enabled', unit,
        check=True,
        silent=True)


def enable(env: Feature, unit: str):
    """Enables a user unit.

    :param env: The feature environment.

    :param unit: The unit name.
    """
    return env.run(
        'systemctl', '--user', 'enable', unit)
