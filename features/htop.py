from . import system

DESCRIPTION = 'Interactive processes viewer'


main = system.package(__name__.rsplit('.')[-1], description=DESCRIPTION)
