import shlex

from . import Feature, feature


def package(package: str, binary: str=None, description: str=None) -> Feature:
    """Defines a package feature.

    :param package: The name of the package. The actual package name can be
        overridden in the configuration.

    :param binary: The binary provided by the package. This is used to check
        whether the feature exists if specified.

    :param description: A description of the package.
    """
    @feature(description or binary or package, set(), package)
    def installer(env: Feature):
        install_package(env, package)

    @installer.checker
    def is_installed(env: Feature) -> bool:
        if binary is not None:
            return present(env, binary)
        else:
            return env.run(
                    *shlex.split(env.configuration['commands']['package_check']),
                    interactive=False,
                    silent=True,
                    check=True,
                    name=env.configuration.get('package_names', {}).get(
                        package, package))

    return installer


def install_package(env: Feature, name: str):
    """Installs a package.

    :param env: The currently handled feature.

    :param name: The generic name of the package.
    """
    env.run(
        *shlex.split(env.configuration['commands']['package_install']),
        name=env.configuration.get('package_names', {}).get(name, name))


def present(env: Feature, name: str) -> bool:
    """Returns whether a binary with a specific name is present on the system.

    :param env: The currently handled feature.

    :param name: The binary name.

    :returns: whether the binary exists
    """
    r = env.run(
        'which', name,
        check=True,
        interactive=False,
        silent=True)
    return r
