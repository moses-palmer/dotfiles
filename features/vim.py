from . import Feature, system

DESCRIPTION = 'Vi IMproved'


main = system.package(__name__.rsplit('.')[-1], description=DESCRIPTION)


def run(env: Feature, *commands: str):
    env.run(
        'vim', *commands,
        interactive=False,
        silent=True)


def runtime(env: Feature) -> str:
    """Returns the path to the vim runtime.

    :param env: The feature environment.

    :return: the base directory for the vim installation
    """
    return env.run(
        'vim', '-e',
        '-T', 'dumb',
        '--cmd', 'exe "set t_cm=\<C-M>" | echo $VIMRUNTIME | quit',
        capture=True,
        interactive=True).strip()
