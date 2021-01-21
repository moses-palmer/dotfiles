from . import Feature, system


main = system.package(__name__.rsplit('.')[-1], 'git')


def clone(env: Feature, repository: str, target: str):
    """Clones a git repository to a specific taget.

    :param env: The feature environment.

    :param repository: The path of the repository.

    :param target: The taget directory. If this is an existing directory, the
        cloned repo will pick its final name from ``repository``.
    """
    env.run(
        'git', 'clone', '${repository}', '${target}',
        repository=repository,
        target=target)
