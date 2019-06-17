from . import Feature, system


system.package(__name__.rsplit('.')[-1])


def run(env: Feature, *commands: str):
    env.run(
        'vim', *commands,
        interactive=False,
        silent=True)
