from . import system

DESCRIPTION = 'Terminal multiplexer'


main = system.package(__name__.rsplit('.')[-1], description=DESCRIPTION)
